
module Annotations2triannon

  # http://iiif.io/model/shared-canvas/1.0/index.html#AnnotationList

  class SharedCanvasAnnotations < Resource

    attr_reader :open_annotations

    def annotation_list?
      iri_type? RDF::SC.AnnotationList
    end

    def open_annotations
      @open_annotations ||= _query_annotations
    end

    # private

    def _query_annotations
      oa_graphs = []
      q = [nil, RDF.type, RDF::OA.Annotation]
      rdf.query(q).each_subject do |subject|
        g = RDF::Graph.new
        rdf.query([subject, nil, nil]) do |s,p,o|
          g << [s,p,o]
          g << rdf_expand_blank_nodes(o) if o.node?
        end
        oa_graphs << g
      end
      oa_graphs
    end
  end

end

