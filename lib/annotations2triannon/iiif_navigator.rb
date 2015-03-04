
module Annotations2triannon

  class IIIFNavigator

    attr_accessor :iiif_collection
    attr_accessor :iiif_manifests
    attr_accessor :iiif_open_annotations
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

    def iiif_manifests?
      ! iiif_manifests.empty?
    end

    def iiif_manifests
      @iiif_manifests ||= iiif_collection.iiif_manifests
    end

    def iiif_annotation_lists
      # http://iiif.io/model/shared-canvas/1.0/index.html#AnnotationList
      return @iiif_annotation_lists unless @iiif_annotation_lists.nil?
      @iiif_annotation_lists = {}
      iiif_manifests.collect do |iiif_manifest|
        @iiif_annotation_lists[iiif_manifest.iri.to_s] = iiif_manifest.annotation_lists
      end
      @iiif_annotation_lists
    end

    def iiif_open_annotations
      return @iiif_open_annotations unless @iiif_open_annotations.nil?
      @iiif_open_annotations = []
      iiif_annotation_lists.each_pair do |iiif_manifest_uri, iiif_annotations_list|
        iiif_annotations_list.each do |iiif_list|
          @iiif_open_annotations << {
              :manifest => iiif_manifest_uri,
              :annotation_list => iiif_list.iri.to_s,
              :open_annotations => iiif_list.open_annotations
          }
        end
      end
      @iiif_open_annotations
    end


    def sc_manifests?
      ! sc_manifests.empty?
    end

    def sc_manifests
      @sc_manifests ||= iiif_collection.sc_manifests
    end

    def sc_annotation_lists
      return @sc_annotation_lists unless @sc_annotation_lists.nil?
      @sc_annotation_lists = {}
      sc_manifests.collect do |sc_manifest|
        @sc_annotation_lists[sc_manifest.iri.to_s] = sc_manifest.annotation_lists
      end
      @sc_annotation_lists
    end

    def sc_open_annotations
      return @sc_open_annotations unless @sc_open_annotations.nil?
      @sc_open_annotations = []
      sc_annotation_lists.each_pair do |sc_manifest_uri, sc_annotations_list|
        sc_annotations_list.each do |sc_list|
          @sc_open_annotations << {
              :manifest => sc_manifest_uri,
              :annotation_list => sc_list.iri.to_s,
              :open_annotations => sc_list.open_annotations
          }
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

