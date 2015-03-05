
module Annotations2triannon

  class Manifest < Resource

    attr_reader :open_annotations

    def manifest?
      sc_manifest? || iiif_manifest?
    end

    def iiif_manifest?
      iri_type? RDF::IIIFPresentation.Manifest
    end

    def sc_manifest?
      iri_type? RDF::SC.Manifest
    end

    def open_annotations
      @open_annotations ||= _query_annotations
    end

    private

    def _query_annotations
      oa_graphs = []
      q = [nil, RDF.type, RDF::OA.Annotation]
      rdf.query(q).each_subject do |subject|
        g = RDF::Graph.new
        rdf.query([subject, nil, nil]) do |s,p,o|
          g << [s,p,o]
          g << rdf_expand_blank_nodes(o) if o.node?
        end
        # TODO: convert g into Annotations2triannon::OpenAnnotation?
        oa_graphs << g
      end
      oa_graphs
    end

  end

end

