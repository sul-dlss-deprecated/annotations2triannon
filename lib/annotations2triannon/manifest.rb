
module Annotations2triannon

  class Manifest < Resource

    attr_reader :annotation_lists
    attr_reader :open_annotations

    def manifest?
       iiif_manifest? || sc_manifest?
    end

    def iiif_manifest?
      iri_type? RDF::IIIFPresentation.Manifest
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

    # TODO: refactor the open_annotations because it is now common
    # to both manifest and annotation_list

    def open_annotations
      @open_annotations ||= collect_open_annotations
    end

    protected

    def collect_open_annotations
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

    # @return a query triple to find RDF::SC.AnnotationList
    def query_sc_annotation_list
      [nil, RDF.type, RDF::SC.AnnotationList]
    end

    # @return a query triple to find RDF::IIIFPresentation.AnnotationList
    def query_iiif_annotation_list
      [nil, RDF.type, RDF::IIIFPresentation.AnnotationList]
    end

    def collect_annotation_list_uris(q)
      rdf.query(q).collect {|s| s.subject }
    end

  end

end

