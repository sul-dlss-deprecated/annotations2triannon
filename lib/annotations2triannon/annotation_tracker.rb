
module Annotations2triannon

  # Annotation tracking
  class AnnotationTracker

    attr_accessor :anno_file
    attr_accessor :config

    def initialize(file_name='anno_tracking.json')
      @config = Annotations2triannon.configuration
      @anno_file = File.join(@config.log_path, file_name)
      FileUtils.touch @anno_file
    end

    # Save the current tracking file to an archive file tagged by timestamp
    def archive
      # Date and time of day for calendar date (basic)
      # %Y%m%dT%H%M%S%z  => 20071119T083748-0600
      time_stamp = DateTime.now.strftime('%Y%m%dT%H%M%S%z')
      ext = File.extname(@anno_file)
      archive = @anno_file.sub(ext, "_#{time_stamp}#{ext}")
      FileUtils.copy(@anno_file, archive)
    end

    # retrieve the anno_tracking data from a file
    # @returns data [Hash]
    def load
      begin
        json_load(@anno_file) || {}
      rescue
        msg = "FAILURE to load annotation tracking file #{@anno_file}"
        @config.logger.error(msg)
        {}
      end
    end

    # Retrieve the annotation URIs from an anno_tracking data file
    # Assumes the annotation tracking data is a hash with a structure:
    # {
    #   manifest_uri: [annotation_list, annotation_list, ]
    # }
    # where each annotation_list is a hash with a structure:
    # {
    #   anno_list_uri: [annotations, annotations, ]
    # }
    # where annotations is an array of hashes, with a structure:
    # {
    #      uri: uri,
    #      chars: body_content_chars
    # }
    # and the uri is a triannon annotation URI.
    # @returns data [Hash]
    # @returns uris [Array<RDF::URI>] An array of URIs to delete from triannon
    def load_uris
      uris = []
      data = load
      data.each_pair do |manifest_uri, anno_lists|
        anno_lists.each_pair do |anno_list_uri, anno_list|
          anno_list.each do |anno_data|
            uris << RDF::URI.new(anno_data['uri'])
          end
        end
      end
      uris
    end

    # persist the anno_tracking data to a file
    # @param data [Hash]
    # @return success [Boolean]
    def save(data)
      begin
        json_save(@anno_file, data)
        puts "Annotation records updated in: #{@anno_file}"
        return true
      rescue
        msg = "FAILURE to save annotation tracking file #{@anno_file}"
        @config.logger.error(msg)
        return false
      end
    end

    # DELETE previous annotations loaded to triannon
    # Accepts an input array of annotation URIs or finds them in the
    # annotation tracking data and removes them from triannon (if they exist).
    # Logs warnings or errors for annotations that do not exist or fail to DELETE.
    # @parameter uris [Array<RDF::URI>] An array of URIs to delete from triannon
    # @return status [Boolean]
    def delete_annotations(uris=[])
      raise ArgumentError, 'uris must be an Array<RDF::URI>' unless uris.instance_of? Array
      tc = TriannonClient::TriannonClient.new
      status = true
      uris = load_uris if uris.empty?
      anno_ids = uris.collect {|uri| tc.annotation_id(uri) }
      # TODO: Enable intersection code below when a better set of annotations
      # can be retrieved from triannon and/or Solr.
      anno_ids.each do |id|
        unless tc.delete_annotation(id)
          @config.logger.error("FAILURE to delete #{id}")
          status = false
        end
      end
      return status

      # Find the intersection of the annotation URIs and
      # the current set of annotations in triannon.
      # Note: the triannon /annotations response may be a limited subset of
      # annotations that does not include any of the previously submitted
      # annotation IDs.  If there are some annotations in the intersection,
      # we have to assume that they are all present and proceed to delete
      # them all.
      # TODO: Use Solr to get a better list of current annotation URIs
      # graph = tc.get_annotations
      # uris = tc.annotation_uris(graph)
      # ids = uris.collect {|uri| tc.annotation_id(uri)}
      # annos_to_remove = anno_ids & ids # intersection of arrays
      # if annos_to_remove.empty?
      #   @config.logger.warn("annotations were not found in triannon.")
      # end
      # if annos_to_remove.length < anno_ids.length
      #   @config.logger.warn("annotations are not current in triannon.")
      # end
      # annos_to_remove.each do |id|
      #   unless tc.delete_annotation(id)
      #     @config.logger.error("FAILURE to delete #{id}")
      #     status = false
      #   end
      # end
      # return status
    end


    private

    def json_save(filename, data)
      File.open(filename,'w') do |f|
        f.write(JSON.pretty_generate(data))
      end
    end

    def json_load(filename)
      if File.exists? filename
        if File.size(filename).to_i > 0
          JSON.parse( File.read(filename) )
        end
      end
    end

  end

end
