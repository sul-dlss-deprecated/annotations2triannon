
module Annotations2triannon

  # A filter to exclude any IIIF namespace content
  class SharedCanvasAnnotationList < AnnotationList

    def annotation_list?
      sc_annotation_list?
    end

    def iiif_annotation_list?
      false
    end

  end

end

