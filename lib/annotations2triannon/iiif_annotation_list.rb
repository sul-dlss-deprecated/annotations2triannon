
module Annotations2triannon

  # A filter to exclude any Shared Canvas namespace content
  class IIIFAnnotationList < AnnotationList

    def annotation_list?
      iiif_annotation_list?
    end

    def sc_annotation_list?
      false
    end

  end

end
