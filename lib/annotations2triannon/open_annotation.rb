require 'rdf/open_annotation'
require 'uuid'

module Annotations2triannon

  # class OpenAnnotation < Resource
  class OpenAnnotation

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
      q = [nil, RDF.type, RDF::OA.Annotation]
      @id = @graph.query(q).collect {|s| s.subject }.first || RDF::URI.parse(UUID.generate)
    end

    def open_annotation?
      # TODO: check rules for basic open annotation
      q = RDF::Query.new
      q << [@id, RDF.type, RDF::OA.Annotation]
      q << [@id, RDF::OA.hasBody, :b]
      q << [@id, RDF::OA.hasTarget, :t]
      @graph.query(q).size > 0
    end

    def insert_annotation
      s = [@id, RDF.type, RDF::OA.Annotation]
      @graph.delete(s)
      @graph.insert(s)
    end

    def is_annotation?
      q = [@id, RDF.type, RDF::OA.Annotation]
      @graph.query(q).size > 0
    end

    def insert_hasTarget(target)
      # TODO: raise ValueError when target is outside hasTarget range?
      @graph.insert([@id, RDF::OA.hasTarget, target])
    end

    # @return [Array] The hasTarget object(s)
    def hasTarget
      q = [nil, RDF::OA.hasTarget, nil]
      @graph.query(q).collect {|s| s.object }
    end

    def hasTarget?
      hasTarget.length > 0
    end

    def insert_hasBody(body)
      # TODO: raise ValueError when body is outside hasBody range?
      @graph.insert([@id, RDF::OA.hasBody, body])
    end

    # @return [Array] The hasBody object(s)
    def hasBody
      q = [nil, RDF::OA.hasBody, nil]
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
      q << [nil, RDF::OA.hasBody, :body]
      q << [:body, RDF.type, RDF::Content.ContentAsText]
      q << [:body, RDF::Content.chars, :body_chars]
      solns = @graph.query q
      solns.each { |soln|
        result << soln.body_chars.value
      }
      result
    end

    def insert_motivatedBy(motivation=RDF::OA.commenting)
      @graph.insert([@id, RDF::OA.motivatedBy, motivation])
    end

    # @return [Array] The motivatedBy object(s)
    def motivatedBy
      q = [nil, RDF::OA.motivatedBy, nil]
      @graph.query(q).collect {|s| s.object }
    end

    def insert_annotatedBy(annotator=nil)
      @graph.insert([@id, RDF::OA.annotatedBy, annotator])
    end

    # @return [Array<String>|nil] The identity for the annotatedBy object(s)
    def annotatedBy
      q = [:s, RDF::OA.annotatedBy, :o]
      @graph.query(q).collect {|s| s.object }
    end

    def insert_annotatedAt(datetime=rdf_now)
      @graph.insert([@id, RDF::OA.annotatedAt, datetime])
    end

    # @return [Array<String>|nil] The datetime from the annotatedAt object(s)
    def annotatedAt
      q = [nil, RDF::OA.annotatedAt, nil]
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
      @graph.delete([nil, RDF::OA.serializedAt, nil])
      @graph << [@id, RDF::OA.serializedAt, rdf_now]
      @graph << [@id, RDF::OA.serializedBy, @@agent]
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

    # OA_CONTEXT_URL = "http://www.w3.org/ns/oa.jsonld"
    # OA_DATED_CONTEXT_URL = "http://www.w3.org/ns/oa-context-20130208.json"
    # IIIF_CONTEXT_URL = "http://iiif.io/api/presentation/2/context.json"

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


    # RDF query to find all objects of a predicate
    # @param predicate [RDF::URI] An RDF predicate, the ?p in ?s ?p ?o
    # @return [Array] The objects of predicate, the ?o in ?s ?p ?o
    def query_predicate_objects(predicate)
      q = [:s, predicate, :o]
      rdf.query(q).collect {|s| s[:o] }
    end

    # RDF query to find all subjects with a predicate
    # @param predicate [RDF::URI] An RDF predicate, the ?p in ?s ?p ?o
    # @return [Array] The subjects with predicate, the ?s in ?s ?p ?o
    def query_predicate_subjects(predicate)
      q = [:s, predicate, :o]
      rdf.query(q).collect {|s| s[:s] }
    end

  end

end

