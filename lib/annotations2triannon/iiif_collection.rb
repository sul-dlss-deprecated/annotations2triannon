
module Annotations2triannon

  class IIIFCollection < Resource

    attr_reader :manifests
    attr_reader :iiif_manifests
    attr_reader :sc_manifests

    def collection?
      # iri_types.filter {|s| s[:o] == 'http://iiif.io/api/presentation/2#Collection' }.length > 0
      iri_type? 'http://iiif.io/api/presentation/2#Collection'
    end

    # def manifests
    #   return @manifests unless @manifests.nil?
    #   sc_m = sc_manifests
    #   iiif_m = iiif_manifests
    #   binding.pry
    # end

    # TODO: Could and/or should a IIIF collection contain sc:Manifests ?
    # http://www.shared-canvas.org/ns/
    def sc_manifests
      return @sc_manifests unless @sc_manifests.nil?
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://www.shared-canvas.org/ns/Manifest> }')
      @sc_manifests = rdf.query(q).collect do |s|
        uri = s[:s].to_s
        Annotations2triannon::SharedCanvasManifest.new(uri)
      end
    end

    def iiif_manifests
      return @iiif_manifests unless @iiif_manifests.nil?
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://iiif.io/api/presentation/2#Manifest> }')
      @iiif_manifests = rdf.query(q).collect do |s|
        uri = s[:s].to_s
        Annotations2triannon::IIIFManifest.new(uri)
      end
    end

  end

end

