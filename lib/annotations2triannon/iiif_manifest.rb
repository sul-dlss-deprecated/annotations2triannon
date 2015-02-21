
module Annotations2triannon

  class IIIFManifest < Resource

    def manifest?
      iri_types.filter {|s| s[:o] == 'http://iiif.io/api/presentation/2#Manifest' }.length > 0
    end

    def open_annotations
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://www.w3.org/ns/oa#Annotation> }')
      rdf.query(q).collect {|s| s[:s] }
    end

    def canvas_annotation_lists
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://www.shared-canvas.org/ns/AnnotationList> }')
      rdf.query(q).collect {|s| s[:s] }
    end

  end

end

