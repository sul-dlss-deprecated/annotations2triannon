
require_relative 'revs_db'
require_relative 'open_annotation'
require_relative 'triannon_client'

module Annotations2triannon

  class Revs

    attr_accessor :db
    attr_accessor :open_annotations

    def initialize
      @db = Annotations2triannon::RevsDb.new
    end

    def open_annotations
      # convert all the annotations
      user_id = nil
      oa_list = []
      @db.annotation_ids.each do |a|
        # the annotation_ids are sorted by user, so there's no
        # need to retrieve the user data for every annotation.
        if user_id != a[:user_id]
          user = user_rdf(a[:user_id])
        end
        annotation = @db.annotation(a[:id])
        oa_list << annotation2oa(annotation, user)
      end
      oa_list
    end

    def open_annotations_as_jsonld
      oa_list = open_annotations
      oa_list.collect {|a| a.as_jsonld }
    end

    def open_annotation(id=nil)
      # Not using a join, because some annotations may be anonymous.
      # join = r.db.annotations.join_table(:inner, r.db.users, :id=>:user_id)
      raise 'Invalid annotation ID' if id.nil?
      # find and convert an annotation by id
      annotation = @db.annotation(id)
      raise "No annotation with id => #{id}" if annotation.nil?
      user = user_rdf(annotation[:user_id])
      annotation2oa(annotation, user)
    end

    def user_rdf(user_id)
      user = @db.user(user_id)
      user_uri = RDF::URI.parse(user[:id])
      user_node = RDF::Node.new(user[:id])
      user_graph = RDF::Graph.new
      user_graph.insert(RDF::Statement.new(user_node, RDF.type, RDF::SCHEMA.Person))
      user_info = RDF::Literal.new("REVS user id: #{user[:id]}")
      user_graph.insert(RDF::Statement.new(user_node, RDF::SCHEMA.description, user_info))
      if user[:public]
        unless user[:first_name].nil? || user[:first_name].empty?
          fn = RDF::Literal.new(user[:first_name])
          user_graph.insert(RDF::Statement.new(user_node, RDF::SCHEMA.givenName, fn))
        end
        unless user[:last_name].nil? || user[:last_name].empty?
          ln = RDF::Literal.new(user[:last_name])
          user_graph.insert(RDF::Statement.new(user_node, RDF::SCHEMA.familyName, ln))
        end
        unless user[:bio].nil? || user[:bio].empty?
          description = RDF::Literal.new(user[:bio])
          user_graph.insert(RDF::Statement.new(user_node, RDF::SCHEMA.description, description))
        end
        unless user[:email].nil? || user[:email].empty?
          email = RDF::URI.parse('mailto:' + user[:email])
          user_graph.insert(RDF::Statement.new(user_node, RDF::SCHEMA.email, email))
        end
        unless user[:url].nil? || user[:url].empty?
          url = user[:url]
          url = url.start_with?('http://') ? url : 'http://' + url
          url = RDF::URI.parse(url)
          user_graph.insert(RDF::Statement.new(user_node, RDF::SCHEMA.url, url))
        end
        unless user[:twitter].nil? || user[:twitter].empty?
          url = user[:twitter]
          unless (url.start_with? 'https://twitter.com') || (url.start_with? 'http://twitter.com')
            url = 'https://twitter.com/' + url
          end
          url = RDF::URI.parse(url)
          user_graph.insert(RDF::Statement.new(user_node, RDF::SCHEMA.url, url))
        end
      end
      {
          :uri => user_uri,
          :node => user_node,
          :graph => user_graph
      }
    end

    # private

    #
    # Mapping a REVS annotation into an Open Annotation
    #
    def annotation2oa(annotation, user)

      begin
        # id --> part of URI for the annotation but, triannon POST will not accept an ID

        # convert the 'druid' into a PURL URI
        purl = 'http://purl.stanford.edu/' + annotation[:druid]
        purl_uri = RDF::URI.parse(purl)

        # convert the 'json' field
        annotation_json = JSON.parse(annotation[:json])
        revs_uri = RDF::URI.parse(annotation_json['context'])
        revs_img_src = annotation_json['src']
        revs_img_uri = RDF::URI.parse(revs_img_src)
        revs_fragments = []
        annotation_json['shapes'].each do |shape|
          # shapes are likely type 'rect'
          if shape['type'] == 'rect'
            # image annotation geometry
            # >> {"x"=>0.3034825870646766, "width"=>0.2611940298507463, "y"=>0.07924528301886792, "height"=>0.3056603773584906}
            # x is % across from top left
            # y is % down from top left
            # width is % across from x
            # height is % down from y
            x = shape['geometry']['x'] * 100
            y = shape['geometry']['y'] * 100
            w = shape['geometry']['width'] * 100
            h = shape['geometry']['height'] * 100
            # media fragment:  #xywh=percent:30.1,16.8,35.1,52.2
            fragment = sprintf '#xywh=percent:%04.1f,%04.1f,%04.1f,%04.1f', x, y, w, h
            revs_fragments << fragment
          end
        end
        revs_img_node = RDF::Node.new
        revs_img_graph = RDF::Graph.new
        revs_img_graph.insert(RDF::Statement.new(revs_img_node, RDF.type, RDF::OpenAnnotation.SpecificResource))
        revs_img_graph.insert(RDF::Statement.new(revs_img_node, RDF::OpenAnnotation.hasSource, revs_img_uri))
        revs_img_graph.insert(RDF::Statement.new(revs_img_uri, RDF.type, RDF::DCMIType.Image))
        revs_fragment_graphs = []
        revs_fragments.each_with_index do |f, i|
          # img_uri = RDF::URI.parse(revs_img_src + fragment)
          # revs_img_uris << img_uri
          f_node = RDF::Node.new(i)
          f_graph = RDF::Graph.new
          f_graph.insert(RDF::Statement.new(f_node, RDF.type, RDF::OpenAnnotation.FragmentSelector))
          f_graph.insert(RDF::Statement.new(f_node, RDF::DC.conformsTo, RDF::MA.MediaFragment))
          f_graph.insert(RDF::Statement.new(f_node, RDF.value, RDF::Literal.new(f)))
          revs_img_graph.insert(RDF::Statement.new(revs_img_node, RDF::OpenAnnotation.hasSelector, f_node))
          revs_fragment_graphs << f_graph
        end

        # oa#hasBody
        # text --> value of cnt:chars property of a ContentAsText body of the annotation
        body_text = RDF::Literal.new(annotation[:text])
        body_graph = RDF::Graph.new
        body_node = RDF::Node.new
        body_graph.insert(RDF::Statement.new(body_node, RDF.type, RDF::Content.ContentAsText))
        body_graph.insert(RDF::Statement.new(body_node, RDF.type, RDF::DCMIType.Text))
        body_graph.insert(RDF::Statement.new(body_node, RDF::Content.chars, body_text))
        body_graph.insert(RDF::Statement.new(body_node, RDF::Content.characterEncoding, 'UTF-8'))

        # oa#annotatedAt
        # created_at --> discard if updated_at is always present
        # updated_at --> oa:annotatedAt
        #
        # > annotation[:created_at].class
        # => Time
        # > annotation[:created_at].utc
        # => 2014-03-25 01:56:01 UTC
        # > annotation[:created_at].to_i  # unix time since epoch
        # => 1395712561
        # > [annotation[:created_at].utc, annotation[:updated_at].utc]
        # => [2014-03-25 01:56:01 UTC, 2014-03-25 01:56:14 UTC]
        #
        # create an RDF literal with datatype, see
        # http://rdf.greggkellogg.net/yard/RDF/Literal.html
        # > RDF::Literal.new(annotation[:created_at]).datatype
        # => #<RDF::Vocabulary::Term:0x3f86333d6ca8 URI:http://www.w3.org/2001/XMLSchema#time>
        # However, this automatic conversion discards the date!
        # > RDF::Literal.new(annotation[:created_at]).to_s
        # => "01:56:01Z"
        # So, an explicit datatype is required, i.e.:
        # > RDF::Literal.new(annotation[:created_at], :datatype => RDF::XSD.dateTime).to_s
        # => "2014-03-25T01:56:01Z"
        created_datetime = RDF::Literal.new(annotation[:created_at].utc, :datatype => RDF::XSD.dateTime)
        updated_datetime = RDF::Literal.new(annotation[:updated_at].utc, :datatype => RDF::XSD.dateTime)
        annotation_datetime = updated_datetime #if annotation[:created_at].utc < annotation[:updated_at].utc

        # Create and populate an Open Annotation instance.
        oa = Annotations2triannon::OpenAnnotation.new
        oa.insert_hasTarget(revs_uri)
        oa.insert_hasTarget(purl_uri)
        oa.insert_hasTarget(revs_img_uri)
        oa.insert_hasTarget(revs_img_node)
        oa.graph.insert(revs_img_graph)
        revs_fragment_graphs.each {|g| oa.graph.insert(g) }
        oa.insert_hasBody(body_node)
        oa.graph.insert(body_graph)
        oa.insert_annotatedAt(annotation_datetime)
        oa.insert_annotatedBy(user[:node])
        oa.graph.insert(user[:graph])
        oa
      rescue => e
        puts e.message
        # binding.pry
        raise e
      end
    end

    # def oa2triannon
    #
    #   # TODO:   - post the open_annotation to triannon-app
    #   # TODO:     - check the http status on the post
    #   # TODO:     - log.debug on success; log.error on errors
    #
    # end

  end

end

