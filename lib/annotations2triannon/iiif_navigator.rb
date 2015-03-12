
module Annotations2triannon

  class IIIFNavigator

    @@config = nil

    attr_accessor :collection
    attr_accessor :manifests
    attr_accessor :annotation_lists
    attr_accessor :open_annotations

    attr_accessor :iiif_collection
    attr_accessor :iiif_manifests
    attr_accessor :iiif_annotation_lists
    attr_accessor :iiif_open_annotations

    attr_accessor :sc_manifests
    attr_accessor :sc_annotation_lists
    attr_accessor :sc_open_annotations


    # @param collection_uri [URI|String] an HTTP URI for a collection
    def initialize(collection_uri)
      @@config ||= Annotations2triannon.configuration
      @uri = RDF::URI.parse(collection_uri)
      @collection = nil
      @manifests = nil
      @annotation_lists = nil
      @open_annotations = nil
      @iiif_collection = nil
      @iiif_manifests = nil
      @iiif_annotation_lists = nil
      @iiif_open_annotations = nil
      @sc_manifests = nil
      @sc_annotation_lists = nil
      @sc_open_annotations = nil
    end


    # ----
    # Collection utilities

    # @return collection - a IIIF Presentation collection
    def collection
      # There may be no distinction between IIIF and SC at the collection level
      iiif_collection
    end

    # @return iiif_collection - a IIIF Presentation collection
    def iiif_collection
      @iiif_collection ||= Annotations2triannon::IIIFCollection.new(@uri)
    end

    # There is no RDF::SC.Collection because SC uses alternate
    # vocabularies for this level of discovery.
    # def sc_collection
    #   @sc_collection ||= Annotations2triannon::SCCollection.new(@uri)
    # end


    # ----
    # Manifest utilities

    # @return [boolean] are there any manifests in the collection?
    def manifests?
      ! manifests.empty?
    end
    # @return manifests [Array] generic manifests, either IIIF or SC manifests
    def manifests
      @manifests ||= collection.manifests
    end

    # IIIF manifests (excluding SC manifests)
    # The RDF type of these manifests is declared in the parent collection.
    # But, watch out, the manifest itself may declare a different RDF type!

    # @return [boolean] are there any IIIF manifests in the collection?
    def iiif_manifests?
      ! iiif_manifests.empty?
    end
    # @return iiif_manifests [Array] IIIF presentation manifests
    def iiif_manifests
      @iiif_manifests ||= collection.iiif_manifests
    end

    # SC manifests (excluding IIIF manifests)
    # The RDF type of these manifests is declared in the parent collection.
    # But, watch out, the manifest itself may declare a different RDF type!

    # @return [boolean] are there any Shared Canvas manifests in the collection?
    def sc_manifests?
      ! sc_manifests.empty?
    end
    # @return sc_manifests [Array] Shared Canvas manifests
    def sc_manifests
      @sc_manifests ||= collection.sc_manifests
    end


    # ----
    # Annotation List utilities

    # @return annotation_lists [Array] generic annotation lists
    def annotation_lists
      return @annotation_lists unless @annotation_lists.nil?
      @annotation_lists = collect_annotation_lists(manifests)
    end

    # @return iiif_annotation_lists [Array] IIIF Presentation annotation lists
    def iiif_annotation_lists
      return @iiif_annotation_lists unless @iiif_annotation_lists.nil?
      @iiif_annotation_lists = collect_annotation_lists(iiif_manifests)
    end

    # @return sc_annotation_lists [Array] Shared Canvas annotation lists
    def sc_annotation_lists
      return @sc_annotation_lists unless @sc_annotation_lists.nil?
      @sc_annotation_lists = collect_annotation_lists(sc_manifests)
    end


    # ----
    # Open Annotation utilities
    # Note that these open annotations are from annotation lists, not
    # directly from manifests.

    # @return open_annotations [Array] Open Annotations from Annotation Lists
    def open_annotations
      @open_annotations ||= collect_open_annotations(annotation_lists)
    end

    # @return iiif_open_annotations [Array] Open Annotations from a IIIF Annotation Lists
    def iiif_open_annotations
      @iiif_open_annotations ||= collect_open_annotations(iiif_annotation_lists)
    end

    # @return sc_open_annotations [Array] Open Annotations from a Shared Canvas Annotation Lists
    def sc_open_annotations
      @sc_open_annotations ||= collect_open_annotations(sc_annotation_lists)
    end


    # TODO: convert IIIF annotations into OA.
    #
    # Mapping a IIF annotation into an Open Annotation
    #
    # def iiif2oa(iiif_annotation)
    # end

    # def oa2triannon
    #
    #   # TODO:   - post the open_annotation to triannon-app
    #   # TODO:     - check the http status on the post
    #   # TODO:     - log.debug on success; log.error on errors
    #
    # end

    private

    def collect_annotation_lists(manifest_arr)
      anno_lists = {}
      manifest_arr.collect {|m| anno_lists[m.iri.to_s] = m.annotation_lists }
      anno_lists
    end

    def collect_open_annotations(annotation_lists)
      oa = {}
      annotation_lists.each_pair do |manifest_uri, annotations_list|
        oa[manifest_uri] = {} if oa[manifest_uri].nil?
        annotations_list.each do |list|
          list_uri = list.iri.to_s
          oa[manifest_uri][list_uri] = list.open_annotations
        end
      end
      oa
    end

  end

end

