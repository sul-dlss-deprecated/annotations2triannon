
module Annotations2triannon

  class IIIFCollection < Resource

    attr_reader :manifests
    attr_reader :iiif_manifests
    attr_reader :sc_manifests

    def collection?
      iri_type? RDF::Vocab::IIIF.Collection
    end

    def manifests
      return @manifests unless @manifests.nil?
      manifests = []
      manifests.push(* manifest_uris(query_iiif_manifests))
      manifests.push(* manifest_uris(query_sc_manifests))
      @manifests = manifests.collect {|m| Annotations2triannon::Manifest.new(m)}
    end

    def sc_manifests
      return @sc_manifests unless @sc_manifests.nil?
      @sc_manifests = manifest_uris(query_sc_manifests).collect do |s|
        Annotations2triannon::SharedCanvasManifest.new(s.subject)
      end
    end

    def iiif_manifests
      return @iiif_manifests unless @iiif_manifests.nil?
      @iiif_manifests = manifest_uris(query_iiif_manifests).collect do |s|
        Annotations2triannon::IIIFManifest.new(s.subject)
      end
    end


    private

    def manifest_uris(q)
      uris = rdf.query(q).collect {|s| s.subject }
      @@config.array_sampler(uris, @@config.limit_manifests)
    end

    def query_iiif_manifests
      [nil, RDF.type, RDF::Vocab::IIIF.Manifest]
    end

    def query_sc_manifests
      [nil, RDF.type, RDF::SC.Manifest]
    end

  end

end

