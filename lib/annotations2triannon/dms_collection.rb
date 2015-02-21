
module Annotations2triannon

  class DMSCollection

    attr_accessor :iiif_collection
    attr_accessor :iiif_manifests
    attr_accessor :sc_manifests
    attr_accessor :sc_annotation_lists
    attr_accessor :sc_open_annotations

    def initialize(uri)
      @uri = RDF::URI.parse(uri) rescue nil
      @iiif_collection = nil
      @iiif_manifests = nil
      @sc_manifests = nil
      @sc_annotation_lists = nil
      @sc_annotations = nil
    end

    def iiif_collection
      @iiif_collection ||= Annotations2triannon::IIIFCollection.new(@uri)
    end

    def iiif_manifests
      @iiif_manifests ||= iiif_collection.manifests.collect do |m|
        Annotations2triannon::IIIFManifest.new(m.to_s)
      end
    end

    def sc_manifests
      @sc_manifests ||= iiif_collection.manifests.collect do |m|
        Annotations2triannon::SharedCanvasManifest.new(m.to_s)
      end
    end

    def sc_annotation_lists
      return @sc_annotation_lists unless @sc_annotation_lists.nil?
      @sc_annotation_lists = {}
      sc_manifests.collect do |sc_manifest|
        @sc_annotation_lists[sc_manifest.iri.to_s] = sc_manifest.annotation_lists.collect do |al|
          Annotations2triannon::SharedCanvasAnnotations.new(al)
        end
      end
      @sc_annotation_lists
    end

    def sc_open_annotations
      return @sc_open_annotations unless @sc_open_annotations.nil?
      @sc_open_annotations = {}
      sc_annotation_lists.each_pair do |sc_manifest_uri, sc_array|
        sc_array.each do |sc_list|
          raise 'This is not an sc:AnnotationList' unless sc_list.annotation_list?
          @sc_open_annotations[ [sc_manifest_uri, sc_list.iri.to_s] ] = sc_list.open_annotations
        end
      end
      @sc_open_annotations
    end



    # private

    # TODO: convert IIF annotations into OA.
    #
    # Mapping a IIF annotation into an Open Annotation
    #
    def iiif2oa(iiif_annotation)

    end

    # def oa2triannon
    #
    #   # TODO:   - post the open_annotation to triannon-app
    #   # TODO:     - check the http status on the post
    #   # TODO:     - log.debug on success; log.error on errors
    #
    # end

  end

end

