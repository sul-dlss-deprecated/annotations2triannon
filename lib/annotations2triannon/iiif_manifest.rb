
module Annotations2triannon

  # A filter to exclude any Shared Canvas namespace content
  class IIIFManifest < Manifest

    def manifest?
       iiif_manifest?
    end

    def sc_manifest?
      false
    end

    def annotation_lists
      return @annotation_lists unless @annotation_lists.nil?
      uris = collect_annotation_list_uris(query_iiif_annotation_list)
      @annotation_lists = uris.collect do |uri|
        Annotations2triannon::AnnotationList.new(uri)
      end
      @annotation_lists
    end

    def sc_annotation_lists
      return @sc_annotation_lists unless @sc_annotation_lists.nil?
      @sc_annotation_lists = []
    end

  end

end

