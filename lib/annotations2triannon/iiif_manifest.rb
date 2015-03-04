
module Annotations2triannon

  class IIIFManifest < Manifest

    attr_reader :annotation_lists

    def annotation_lists
      return @annotation_lists unless @annotation_lists.nil?
      q = SPARQL.parse('SELECT * WHERE { ?s a <http://iiif.io/model/shared-canvas/1.0/index.html#AnnotationList>}')
      @annotation_lists = rdf.query(q).collect do |s|
        uri = s[:s].to_s
        Annotations2triannon::IIIFAnnotations.new(uri)
      end
      @annotation_lists
    end

  end

end

