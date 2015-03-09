require 'uuid'

module Annotations2triannon

  # class OpenAnnotation < Resource
  class OpenAnnotation

    OA = RDF::Vocab::OA
    OA_ROOT_URL = 'http://www.w3.org/ns/oa'
    CONTEXT_OA_URL = OA_ROOT_URL + '.jsonld'
    CONTEXT_OA_DATED_URL = OA_ROOT_URL + '-context-20130208.json'
    IIIF_ROOT_URL = 'http://iiif.io/api/presentation/2/'
    CONTEXT_IIIF_URL = IIIF_ROOT_URL + 'context.json'

    attr_accessor :id
    attr_accessor :graph # an RDF::Graph

    # instantiate this class
    # @param graph [RDF::Graph] for an open annotation
    # @param id [UUID|URI|String] to identify an open annotation
    def initialize(graph=RDF::Graph.new, id=nil)
      @@agent ||= Annotations2triannon::AGENT
      raise TypeError, 'graph must be RDF::Graph instance' unless graph.instance_of? RDF::Graph
      if graph.empty?
        # create a new open annotation
        @graph = graph
        id.nil? ? @id = get_id : @id = RDF::URI.parse(id)
        insert_annotation
      else
        @graph = graph
        raise TypeError, 'graph must be an open annotation' unless is_annotation?
        if id.nil?
          @id = get_id
        else
        end
      end
    end

    def get_id
      return @id unless @id.nil?
      q = [nil, RDF.type, OA.Annotation]
      @id = @graph.query(q).collect {|s| s.subject }.first || RDF::URI.parse(UUID.generate)
    end

    # @return [boolean] true if RDF.type is OA.Annotation, with OA.hasBody and OA.hasTarget
    def open_annotation?
      # TODO: check rules for basic open annotation
      q = RDF::Query.new
      q << [@id, RDF.type, OA.Annotation]
      q << [@id, OA.hasBody, :b]
      q << [@id, OA.hasTarget, :t]
      @graph.query(q).size > 0
    end

    def insert_annotation
      s = [@id, RDF.type, OA.Annotation]
      @graph.delete(s)
      @graph.insert(s)
    end

    # @return [boolean] true if RDF.type is OA.Annotation
    def is_annotation?
      q = [@id, RDF.type, OA.Annotation]
      @graph.query(q).size > 0
    end

    def insert_hasTarget(target)
      # TODO: raise ValueError when target is outside hasTarget range?
      @graph.insert([@id, OA.hasTarget, target])
    end

    # @return [Array] The hasTarget object(s)
    def hasTarget
      q = [nil, OA.hasTarget, nil]
      @graph.query(q).collect {|s| s.object }
    end

    def hasTarget?
      hasTarget.length > 0
    end

    def insert_hasBody(body)
      # TODO: raise ValueError when body is outside hasBody range?
      @graph.insert([@id, OA.hasBody, body])
    end

    # @return [Array] The hasBody object(s)
    def hasBody
      q = [nil, OA.hasBody, nil]
      @graph.query(q).collect {|s| s.object }
    end

    def hasBody?
      hasBody.length > 0
    end

    # For all bodies that are of type ContentAsText, get the characters as a single String in the returned Array.
    # @return [Array<String>] body chars as Strings, in an Array (one element for each contentAsText body)
    def body_chars
      result = []
      q = RDF::Query.new
      q << [nil, OA.hasBody, :body]
      q << [:body, RDF.type, RDF::Content.ContentAsText]
      q << [:body, RDF::Content.chars, :body_chars]
      solns = @graph.query q
      solns.each { |soln|
        result << soln.body_chars.value
      }
      result
    end

    def insert_motivatedBy(motivation=OA.commenting)
      @graph.insert([@id, OA.motivatedBy, motivation])
    end

    # @return [Array] The motivatedBy object(s)
    def motivatedBy
      q = [nil, OA.motivatedBy, nil]
      @graph.query(q).collect {|s| s.object }
    end

    def insert_annotatedBy(annotator=nil)
      @graph.insert([@id, OA.annotatedBy, annotator])
    end

    # @return [Array<String>|nil] The identity for the annotatedBy object(s)
    def annotatedBy
      q = [:s, OA.annotatedBy, :o]
      @graph.query(q).collect {|s| s.object }
    end

    def insert_annotatedAt(datetime=rdf_now)
      @graph.insert([@id, OA.annotatedAt, datetime])
    end

    # @return [Array<String>|nil] The datetime from the annotatedAt object(s)
    def annotatedAt
      q = [nil, OA.annotatedAt, nil]
      @graph.query(q).collect {|s| s.object }
    end

    def rdf_now
      RDF::Literal.new(Time.now.utc, :datatype => RDF::XSD.dateTime)
    end

    def provenance
      # http://www.openannotation.org/spec/core/core.html#Provenance
      # When adding the agent, ensure it's not there already, also
      # an open annotation cannot have more than one oa:serializedAt.
      @graph.delete([nil,nil,@@agent])
      @graph.delete([nil, OA.serializedAt, nil])
      @graph << [@id, OA.serializedAt, rdf_now]
      @graph << [@id, OA.serializedBy, @@agent]
    end

    # A json-ld representation of the open annotation
    def as_jsonld
      provenance
      JSON::LD::API::fromRdf(@graph)
    end

    # A json-ld string representation of the open annotation
    def to_jsonld
      provenance
      @graph.dump(:jsonld, standard_prefixes: true)
    end

    # A turtle string representation of the open annotation
    def to_ttl
      provenance
      @graph.dump(:ttl, standard_prefixes: true)
    end

    # TODO: try using the code at
    # https://github.com/sul-dlss/triannon/blob/master/lib/triannon/graph.rb#L36-50

    # # @return json-ld representation of graph with OpenAnnotation context as a url
    # def jsonld_oa
    #   inline_context = @graph.dump(:jsonld, :context => Triannon::JsonldContext::OA_CONTEXT_URL)
    #   hash_from_json = JSON.parse(inline_context)
    #   hash_from_json["@context"] = Triannon::JsonldContext::OA_CONTEXT_URL
    #   hash_from_json.to_json
    #
    #   # TODO: return from json to graph?
    #   #RDF::Graph.new << JSON::LD::API.toRdf(input)
    # end
    #
    # # @return json-ld representation of graph with IIIF context as a url
    # def jsonld_iiif
    #   inline_context = @graph.dump(:jsonld, :context => Triannon::JsonldContext::IIIF_CONTEXT_URL)
    #   hash_from_json = JSON.parse(inline_context)
    #   hash_from_json["@context"] = Triannon::JsonldContext::IIIF_CONTEXT_URL
    #   hash_from_json.to_json
    # end


  end

end

