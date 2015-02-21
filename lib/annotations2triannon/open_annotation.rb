require 'rdf/open_annotation'
require 'uuid'

module Annotations2triannon

  # class OpenAnnotation < Resource
  class OpenAnnotation

    @@agent = RDF::URI.parse('https://github.com/sul-dlss/annotations2triannon')

    attr_accessor :id
    attr_accessor :graph # an RDF::Graph

    def initialize(id=UUID.generate)
      @id = RDF::URI.parse(id)
      @graph = RDF::Graph.new
      @graph.insert([@id, RDF.type, RDF::OpenAnnotation.Annotation])
      insert_motivatedBy
      provenance
    end

    def insert_hasTarget(target=nil)
      @graph.insert([@id, RDF::OpenAnnotation.hasTarget, target])
    end

    def insert_hasBody(body=nil)
      @graph.insert([@id, RDF::OpenAnnotation.hasBody, body])
    end

    def insert_motivatedBy(motivation=RDF::OpenAnnotation.commenting)
      @graph.insert([@id, RDF::OpenAnnotation.motivatedBy, motivation])
    end

    def insert_annotatedBy(annotator=nil)
      @graph.insert([@id, RDF::OpenAnnotation.annotatedBy, annotator])
    end

    def insert_annotatedAt(datetime=rdf_now)
      @graph.insert([@id, RDF::OpenAnnotation.annotatedAt, datetime])
    end

    def rdf_now
      RDF::Literal.new(Time.now.utc, :datatype => RDF::XSD.dateTime)
    end

    def provenance
      # http://www.openannotation.org/spec/core/core.html#Provenance
      # When adding the agent, ensure it's not there already, also
      # an open annotation cannot have more than one oa:serializedAt.
      @graph.delete([nil,nil,@@agent])
      @graph.delete([nil, RDF::OpenAnnotation.serializedAt, nil])
      @graph << [@id, RDF::OpenAnnotation.serializedAt, rdf_now]
      @graph << [@id, RDF::OpenAnnotation.serializedBy, @@agent]
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

