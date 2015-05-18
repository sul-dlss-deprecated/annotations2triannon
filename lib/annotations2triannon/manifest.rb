
module Annotations2triannon

  class Manifest < Resource

    include OpenAnnotationHarvest

    attr_reader :annotation_lists
    attr_reader :open_annotations

    def manifest?
       iiif_manifest? || sc_manifest?
    end

    def iiif_manifest?
      iri_type? RDF::Vocab::IIIF.Manifest
    end

    def sc_manifest?
      iri_type? RDF::SC.Manifest
    end

    def annotation_lists
      return @annotation_lists unless @annotation_lists.nil?
      uris = []
      uris.push(* collect_annotation_list_uris(query_iiif_annotation_list))
      uris.push(* collect_annotation_list_uris(query_sc_annotation_list))
      @annotation_lists = uris.collect do |uri|
        Annotations2triannon::AnnotationList.new(uri)
      end
      @annotation_lists
    end

    def iiif_annotation_lists
      return @iiif_annotation_lists unless @iiif_annotation_lists.nil?
      uris = collect_annotation_list_uris(query_iiif_annotation_list)
      @iiif_annotation_lists = uris.collect do |uri|
        Annotations2triannon::IIIFAnnotationList.new(uri)
      end
      @iiif_annotation_lists
    end

    def sc_annotation_lists
      return @sc_annotation_lists unless @sc_annotation_lists.nil?
      uris = collect_annotation_list_uris(query_sc_annotation_list)
      @sc_annotation_lists = uris.collect do |uri|
        Annotations2triannon::SharedCanvasAnnotationList.new(uri)
      end
      @sc_annotation_lists
    end

    def open_annotations
      return @open_annotations unless @open_annotations.nil?
      begin
        oa_graphs = collect_open_annotations
        oa_graphs = oa_graphs.sample(@@config.limit_openannos) if @@config.limit_openannos > 0
        oa_graphs
      rescue => e
        binding.pry if @@config.debug
        @@config.logger.error(e.message)
      end
    end


    protected

    # @return a query triple to find RDF::SC.AnnotationList
    def query_sc_annotation_list
      [nil, RDF.type, RDF::SC.AnnotationList]
    end

    # @return a query triple to find RDF::Vocab::IIIF.AnnotationList
    def query_iiif_annotation_list
      [nil, RDF.type, RDF::Vocab::IIIF.AnnotationList]
    end

    def collect_annotation_list_uris(q)
      uris = rdf.query(q).collect {|s| s.subject }
      @@config.array_sampler(uris, @@config.limit_annolists)
    end

  end

end

