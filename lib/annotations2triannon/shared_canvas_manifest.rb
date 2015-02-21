
module Annotations2triannon

  class SharedCanvasManifest < Resource

    def manifest?
      iri_types.filter {|s| s[:o] == 'http://www.shared-canvas.org/ns/Manifest' }.length > 0
    end

    def annotation_lists
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://www.shared-canvas.org/ns/AnnotationList> }')
      rdf.query(q).collect {|s| s[:s] }
    end

    def open_annotations
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://www.w3.org/ns/oa#Annotation> }')
      rdf.query(q).collect {|s| s[:s] }
    end

  end

end

