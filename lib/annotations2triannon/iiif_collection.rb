
module Annotations2triannon

  class IIIFCollection < Resource

    def manifests
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://iiif.io/api/presentation/2#Manifest> }')
      rdf.query(q).collect {|s| s[:s] }
    end

    def collection?
      iri_types.filter {|s| s[:o] == 'http://iiif.io/api/presentation/2#Collection' }.length > 0
    end

  end

end

