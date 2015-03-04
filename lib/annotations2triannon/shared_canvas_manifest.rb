
module Annotations2triannon

  class SharedCanvasManifest < Manifest

    attr_reader :annotation_lists

    def annotation_lists
      return @annotation_lists unless @annotation_lists.nil?
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://www.shared-canvas.org/ns/AnnotationList> }')
      @annotation_lists = rdf.query(q).collect do |s|
        uri = s[:s].to_s
        Annotations2triannon::SharedCanvasAnnotations.new(uri)
      end
      @annotation_lists
    end

  end

end

