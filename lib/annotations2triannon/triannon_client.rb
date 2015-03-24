
module Annotations2triannon

  class TriannonClient

    @@config = nil
    @@log = Logger.new('log/triannon.log')

    attr_accessor :site

    def initialize
      # Configure triannon-app service
      @@config ||= Annotations2triannon.configuration
      @config = {}
      @config['host'] = ENV['TRIANNON_HOST'] || 'http://localhost:3000'
      @config['user'] = ENV['TRIANNON_USER'] || ''
      @config['pass'] = ENV['TRIANNON_PASS'] || ''
      @site = RestClient::Resource.new(
        @config['host'],
        :user => @config['user'],
        :password => @config['pass'],
        :open_timeout => 5,  #seconds
        :read_timeout => 20, #seconds
      )
    end

    def post_annotation(oa)
      post_data = {
        "commit" => "Create Annotation",
        "annotation" => { "data" => oa.to_jsonld_oa }
      }
      response = nil
      tries = 0
      begin
        tries += 1
        response = @site["/annotations/"].post post_data, :content_type => :json
      rescue
        sleep 1*tries
        retry if tries < 3
        binding.pry if @@config.debug
      end
      if response.nil? || response.code != 201
        @@config.logger.error("Failed to POST to triannon:annotations/")
      else
        @@config.logger.info("Success: POST to triannon:annotations/")
      end
    end

    # GET annotations and annotation
    #
    # use HTTP Accept header with mime type to indicate desired
    # format ** default: jsonld ** also supports turtle, rdfxml, html
    # ** see https://github.com/sul-dlss/triannon/blob/master/app/controllers/triannon/annotations_controller.rb #show method for mime formats accepted
    #
    # JSON-LD context
    #
    # You can request IIIF or OA context for jsonld. You can use either of
    # these methods (with the correct HTTP Accept header):
    #
    # GET: http://(host)/annotations/iiif/(anno_id)
    # GET: http://(host)/annotations/(anno_id)?jsonld_context=iiif
    #
    # GET: http://(host)/annotations/oa/(anno_id)
    # GET: http://(host)/annotations/(anno_id)?jsonld_context=oa
    #
    # Note that OA (Open Annotation) is the default context if none is specified.

    def get_annotations(content_type=nil)
      # Get a list of annotations
      if content_type.nil?
        # assume we want to get an RDF graph
        uri = "#{@site.url}/annotations"
        RDF::Graph.load(uri)
      else
        # content_type options should include: :html, :xml, :rdf, :json
        content_type = content_type.to_sym
        @site["/annotations"].get({:accept => content_type})
      end
    end

    def get_annotation(id, content_type=nil)
      # Get a particular annotation
      if content_type.nil?
        # assume we want to get an RDF graph
        uri = "#{@site.url}/annotations/#{id}"
        RDF::Graph.load(uri)
      else
        # content_type options should include: :html, :xml, :rdf, :json
        content_type = content_type.to_sym
        @site["/annotations/#{id}"].get({:accept => content_type})
      end
    end

  end

end

