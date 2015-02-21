
module Annotations2triannon

  class SharedCanvasAnnotations < Resource

    attr_reader :open_annotations

    def annotation_list?
      iri_types.filter {|s| s[:o] == 'http://www.shared-canvas.org/ns/AnnotationList' }.length > 0
    end

    def open_annotations
      @open_annotations ||= _query_annotations
    end

    # private

    def _query_annotations
      oa_graphs = []
      rdf.query([nil, RDF.type, RDF::OpenAnnotation.Annotation]).each_subject do |subject|
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

