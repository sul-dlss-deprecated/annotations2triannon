
require_relative 'revs_db'

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
      user_id = sprintf 'revs_user_%04d', user[:id]
      user_uri = RDF::URI.parse(user_id)
      # avoid creation of blank nodes?
      # user_node = RDF::Node.new(user_uri)
      user_graph = RDF::Graph.new
      user_graph.insert([user_uri, RDF.type, RDF::SCHEMA.Person])
      # user_info = RDF::Literal.new("REVS user id: #{user[:id]}")
      # user_graph.insert([user_uri, RDF::SCHEMA.description, user_info])
      if user[:public]
        unless user[:first_name].nil? || user[:first_name].empty?
          # TODO: add a language tag?
          #fn = RDF::Literal.new(user[:first_name], :language => :en)
          fn = RDF::Literal.new(user[:first_name])
          user_graph.insert([user_uri, RDF::SCHEMA.givenName, fn])
        end
        unless user[:last_name].nil? || user[:last_name].empty?
          # TODO: add a language tag?
          #ln = RDF::Literal.new(user[:last_name], :language => :en)
          ln = RDF::Literal.new(user[:last_name])
          user_graph.insert([user_uri, RDF::SCHEMA.familyName, ln])
        end
        unless user[:bio].nil? || user[:bio].empty?
          # TODO: add a language tag?
          #description = RDF::Literal.new(user[:bio], :language => :en)
          description = RDF::Literal.new(user[:bio])
          user_graph.insert([user_uri, RDF::SCHEMA.description, description])
        end
        unless user[:email].nil? || user[:email].empty?
          email = RDF::URI.parse('mailto:' + user[:email])
          user_graph.insert([user_uri, RDF::SCHEMA.email, email])
        end
        unless user[:url].nil? || user[:url].empty?
          url = user[:url]
          url = url.start_with?('http://') ? url : 'http://' + url
          url = RDF::URI.parse(url)
          user_graph.insert([user_uri, RDF::SCHEMA.url, url])
        end
        unless user[:twitter].nil? || user[:twitter].empty?
          url = user[:twitter]
          unless (url.start_with? 'https://twitter.com') || (url.start_with? 'http://twitter.com')
            url = 'https://twitter.com/' + url
          end
          url = RDF::URI.parse(url)
          user_graph.insert([user_uri, RDF::SCHEMA.url, url])
        end
      end
      {
          :uri => user_uri,
          # :node => user_node,
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
        annotation_id = sprintf 'revs_annotation_%04d', annotation[:id]

        # convert the 'druid' into a PURL URI
        purl = 'http://purl.stanford.edu/' + annotation[:druid]
        purl_uri = RDF::URI.parse(purl)

        # Commentary on the annotation json field
        #
        # > for each row of the annotation table (in mysql), can the 'shapes' array
        # contain more than one entry?
        #
        # Shapes can currently only contain one entry, and are currently always
        # rectangular. This data structure and shape implementation is a result of our
        # use of the annotorious plugin, which is not guaranteed across projects or even
        # in Revs in the long term.
        #
        # > if so, this suggests that a 'text' annotation might refer to more than
        # one segment or region of a REVS image?
        #
        # Not at the moment. Not sure why it is an array. Perhaps so you can store
        # multiple annotations about the same image in one row instead of many, but we
        # do not do this for various reasons.
        #
        # > What is the 'context' field?  Would you rather use the 'context' field than
        # the 'src' field as the target of an open annotation (OA)?
        #
        # Context is just what annotorious uses for the src target.  Again, we just used
        # their vocabulary for ease of implementation.  If we were to use a different
        # back-end data store at some point, we could always transform into and out-of
        # their specific json structure as needed.
        #

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
        revs_img_graph = RDF::Graph.new
        # revs_img_node = RDF::Node.new(revs_img_uri)
        # revs_img_graph.insert([revs_img_node, RDF.type, RDF::OpenAnnotation.SpecificResource])
        # revs_img_graph.insert([revs_img_node, RDF::OpenAnnotation.hasSource, revs_img_uri])
        revs_img_graph.insert([revs_uri, RDF.type, RDF::OpenAnnotation.SpecificResource])
        revs_img_graph.insert([revs_uri, RDF::OpenAnnotation.hasSource, revs_img_uri])
        revs_img_graph.insert([revs_img_uri, RDF.type, RDF::DCMIType.Image])
        # Note: it's most likely there is only one fragment in a REVS annotation.
        revs_fragment_graphs = []
        revs_fragments.each_with_index do |f, i|
          # img_uri = RDF::URI.parse(revs_img_src + fragment)
          # revs_img_uris << img_uri
          f_id = sprintf '%s_fragment_%02d', annotation_id, i
          f_uri = RDF::URI.parse(f_id)
          f_graph = RDF::Graph.new
          # avoid creation of blank nodes?
          # f_node = RDF::Node.new(f_uri)
          # f_graph.insert([f_node, RDF.type, RDF::OpenAnnotation.FragmentSelector])
          # f_graph.insert([f_node, RDF::DC.conformsTo, RDF::MA.MediaFragment])
          # f_graph.insert([f_node, RDF.value, RDF::Literal.new(f)])
          # revs_img_graph.insert([revs_img_node, RDF::OpenAnnotation.hasSelector, f_node])
          f_graph.insert([f_uri, RDF.type, RDF::OpenAnnotation.FragmentSelector])
          f_graph.insert([f_uri, RDF::DC.conformsTo, RDF::MA.MediaFragment])
          f_graph.insert([f_uri, RDF.value, RDF::Literal.new(f)])
          revs_img_graph.insert([revs_uri, RDF::OpenAnnotation.hasSelector, f_uri])
          revs_fragment_graphs << f_graph
        end

        # oa#hasBody
        # text --> value of cnt:chars property of a ContentAsText body of the annotation
        body_id = sprintf '%s_comment', annotation_id
        body_uri = RDF::URI.parse(body_id)
        # TODO: add a language tag?
        #body_text = RDF::Literal.new(annotation[:text], :language => :en)
        body_text = RDF::Literal.new(annotation[:text])
        body_graph = RDF::Graph.new
        # avoid creation of blank nodes?
        # body_node = RDF::Node.uuid
        # body_node = RDF::Node.new(annotation[:id])
        body_graph.insert([body_uri, RDF.type, RDF::Content.ContentAsText])
        body_graph.insert([body_uri, RDF.type, RDF::DCMIType.Text])
        body_graph.insert([body_uri, RDF::Content.chars, body_text])
        body_graph.insert([body_uri, RDF::Content.characterEncoding, 'UTF-8'])

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
        # oa.insert_hasTarget(revs_img_node)
        oa.graph.insert(revs_img_graph)
        revs_fragment_graphs.each {|g| oa.graph.insert(g) }
        # to enable the blank node, change body_graph to use body_node instead of body_uri
        # oa.insert_hasBody(body_node)
        oa.insert_hasBody(body_uri)
        oa.graph.insert(body_graph)
        oa.insert_annotatedAt(annotation_datetime)
        # to enable the blank node, change user_graph to use user_node instead of user_uri
        # oa.insert_annotatedBy(user[:node])
        oa.insert_annotatedBy(user[:uri])
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

