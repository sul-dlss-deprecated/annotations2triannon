
module Annotations2triannon

  # A filter to exclude any IIIF namespace content
  class SharedCanvasManifest < Manifest

    def manifest?
      sc_manifest?
    end

    def iiif_manifest?
      false
    end

    def annotation_lists
      return @annotation_lists unless @annotation_lists.nil?
      uris = collect_annotation_list_uris(query_sc_annotation_list)
      @annotation_lists = uris.collect do |uri|
        Annotations2triannon::AnnotationList.new(uri)
      end
      @annotation_lists
    end

    def iiif_annotation_lists
      return @iiif_annotation_lists unless @iiif_annotation_lists.nil?
      @iiif_annotation_lists = []
    end

  end

end

