
module Annotations2triannon

  class AnnotationList < Resource

    include OpenAnnotationHarvest

    attr_reader :open_annotations

    def annotation_list?
      sc_annotation_list? || iiif_annotation_list?
    end

    def iiif_annotation_list?
      iri_type? RDF::IIIFPresentation.AnnotationList
    end

    def sc_annotation_list?
      iri_type? RDF::SC.AnnotationList
    end

    def open_annotations
      return @open_annotations unless @open_annotations.nil?
      begin
        oa_graphs = collect_open_annotations(rdf)
        oa_graphs = oa_graphs.sample(@@config.limit_openannos) if @@config.limit_openannos > 0
        oa_graphs
      rescue => e
        binding.pry if @@config.debug
        @@config.logger.error(e.message)
      end
    end

    # protected

    # def collect_open_annotations
    #   oa_graphs = []
    #   begin
    #     q = [nil, RDF.type, RDF::Vocab::OA.Annotation]
    #     rdf.query(q).each_subject do |subject|
    #       g = RDF::Graph.new
    #       rdf.query([subject, nil, nil]) do |s,p,o|
    #         g << [s,p,o]
    #         g << rdf_expand_blank_nodes(o) if o.node?
    #       end
    #       # TODO: convert g into Annotations2triannon::OpenAnnotation?
    #       oa_graphs << g
    #     end
    #   rescue => e
    #     binding.pry if @@config.debug
    #     @@config.logger.error(e.message)
    #   end
    #   oa_graphs = oa_graphs.sample(@@config.limit_openannos) if @@config.limit_openannos > 0
    #   oa_graphs
    # end

  end

end

