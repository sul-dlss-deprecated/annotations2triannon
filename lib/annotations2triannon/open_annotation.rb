require 'uuid'

module Annotations2triannon

  # class OpenAnnotation < Resource
  class OpenAnnotation

    CONTENT = RDF::Vocab::CNT
    OA = RDF::Vocab::OA
    OA_CONTEXT = 'http://www.w3.org/ns/oa.jsonld'
    IIIF_CONTEXT = 'http://iiif.io/api/presentation/2/context.json'

    attr_accessor :id
    attr_accessor :graph # an RDF::Graph

    # instantiate this class
    # @param graph [RDF::Graph] for an open annotation
    # @param id [UUID|URI|String] to identify an open annotation
    def initialize(graph=RDF::Graph.new, id=nil)
      @@agent ||= Annotations2triannon::AGENT
      raise ArgumentError, 'graph must be RDF::Graph instance' unless graph.instance_of? RDF::Graph
      if graph.empty?
        # create a new open annotation
        @graph = graph
        id.nil? ? @id = get_id : @id = RDF::URI.parse(id)
        insert_annotation
      else
        @graph = graph
        raise ArgumentError, 'graph must be an open annotation' unless is_annotation?
        id.nil? ? @id = get_id : @id = id
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

    def body_graph
      return @body_graph unless @body_graph.nil?
      g = RDF::Graph.new
      hasBody.each do |b|
        @graph.query( [b, :p, :o] ).each_statement {|s| g << s}
        # if b.uri?
        #   begin
        #     b_resource = Resource.new(b)
        #     b_resource.rdf.each_statement {|s| g << s}
        #   rescue
        #     # Nothing to be done here; the Resource#rdf method
        #     # will log errors in RDF retrieval
        #   end
        # end
      end
      @body_graph = g
    end

    def body_contentAsText
      body_type CONTENT.ContentAsText
    end

    def body_contentAsText?
      body_contentAsText.size > 0
    end

    # For all bodies that are of type ContentAsText, get the characters as a single String in the returned Array.
    # @return [Array<String>] body chars as Strings, in an Array (one element for each contentAsText body)
    def body_contentChars
      q = RDF::Query.new
      q << [:body, RDF.type, CONTENT.ContentAsText]
      q << [:body, CONTENT.chars, :body_chars]
      body_graph.query(q).collect {|s| s.body_chars.value }
    end

    def body_semanticTag
      body_type OA.SemanticTag
    end

    def body_semanticTag?
      body_semanticTag.size > 0
    end

    def body_type(uri=nil)
      uri = RDF::URI.parse(uri) unless uri.nil?
      body_graph.query([:body, RDF.type, uri])
    end

    # Insert an ?o for [id, OA.motivatedBy, ?o] where ?o is 'motivation'
    # @param motivation [String|URI] An open annotation motivation
    def insert_motivatedBy(motivation)
      # TODO: only accept values allowed by OA.motivationBy range?
      motivation = RDF::URI.parse(motivation)
      @graph.insert([@id, OA.motivatedBy, motivation])
    end

    # Find any matching ?o for ?s OA.motivatedBy ?o where ?o is 'uri'
    # @param uri [RDF::URI|String|nil] Any object of a motivatedBy predicate
    # @return [Array] The motivatedBy object(s)
    def motivatedBy(uri=nil)
      uri = RDF::URI.parse(uri) unless uri.nil?
      q = [nil, OA.motivatedBy, uri]
      @graph.query(q).collect {|s| s.object }
    end

    # Are there any matching ?o for [?s, OA.motivatedBy, ?o] where ?o is 'uri'
    # @param uri [RDF::URI|String|nil] Any object of a motivatedBy predicate
    # @return [boolean] True if the open annotation has any motivatedBy 'uri'
    def motivatedBy?(uri=nil)
      motivatedBy(uri).length > 0
    end

    # Insert [id, OA.motivatedBy, OA.commenting]
    def insert_motivatedByCommenting
      insert_motivatedBy OA.commenting
    end

    # Find all the matching ?s for [?s, OA.motivatedBy, OA.commenting]
    def motivatedByCommenting
      q = [nil, OA.motivatedBy, OA.commenting]
      @graph.query(q).collect {|s| s.subject }
    end

    # Are there any matching ?s for [?s, OA.motivatedBy, OA.commenting]
    def motivatedByCommenting?
      motivatedByCommenting.length > 0
    end

    # Insert [id, OA.motivatedBy, OA.tagging]
    def insert_motivatedByTagging
      insert_motivatedBy OA.tagging
    end

    # Find all the matching ?s for [?s, OA.motivatedBy, OA.tagging]
    def motivatedByTagging
      q = [nil, OA.motivatedBy, OA.tagging]
      @graph.query(q).collect {|s| s.subject }
    end

    # Are there any matching ?s for [?s, OA.motivatedBy, OA.tagging]
    def motivatedByTagging?
      motivatedByTagging.length > 0
    end

    def insert_annotatedBy(annotator=nil)
      @graph.insert([@id, OA.annotatedBy, annotator])
    end

    # @return [Array<String>|nil] The identity for the annotatedBy object(s)
    def annotatedBy
      q = [:s, OA.annotatedBy, :o]
      @graph.query(q).collect {|s| s.object }
    end

    # @param uri [RDF::URI|String|nil] Any object of an annotatedBy predicate
    # @return [boolean] True if the open annotation has any annotatedBy 'uri'
    def annotatedBy?(uri=nil)
      uri = RDF::URI.parse(uri) unless uri.nil?
      q = [nil, OA.annotatedBy, uri]
      @graph.query(q).size > 0
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
      JSON::LD::API::fromRDF(@graph)
    end

    # @param context [String] A JSON-LD context URI
    # @return json-ld representation of graph with default context
    def to_jsonld(context=nil)
      provenance
      if context.nil?
        @graph.dump(:jsonld, standard_prefixes: true)
      else
        @graph.dump(:jsonld, standard_prefixes: true, context: context)
      end
    end

    # @return json-ld representation of graph with IIIF context
    def to_jsonld_iiif
      to_jsonld IIIF_CONTEXT
    end

    # @return json-ld representation of graph with OpenAnnotation context
    def to_jsonld_oa
      to_jsonld OA_CONTEXT
    end

    # A turtle string representation of the open annotation
    def to_ttl
      provenance
      @graph.dump(:ttl, standard_prefixes: true)
    end

  end

end

