
module Annotations2triannon

  class TriannonClient

    @@log = Logger.new('log/triannon.log')

    attr_accessor :site

    def initialize
      # Configure triannon-app service
      @config = {}
      @config['host'] = ENV['TRIANNON_HOST'] || 'localhost'
      @config['user'] = ENV['TRIANNON_USER'] || ''
      @config['pass'] = ENV['TRIANNON_PASS'] || ''
      auth_str = ''
      unless @config['user'].empty?
        auth_str += @config['user']
        auth_str += ":#{@config['pass']}" unless @config['pass'].empty?
      end
      uri = 'http://'
      uri += "#{auth_str}@" if auth_str.length > 1
      uri += @config['host']
      @site = RestClient::Resource.new(uri)
    end

    # Example open annotation post data, from:
    # https://github.com/sul-dlss/triannon/blob/master/spec/fixtures/annotations/body-chars.ttl
    #
    # <> a <http://www.w3.org/ns/oa#Annotation>;
    # <http://www.w3.org/ns/oa#hasBody> [
    # a <http://www.w3.org/2011/content#ContentAsText>,
    # <http://purl.org/dc/dcmitype/Text>;
    # <http://www.w3.org/2011/content#chars> "I love this!"
    # ];
    # <http://www.w3.org/ns/oa#hasTarget> <http://purl.stanford.edu/kq131cs7229>;
    # <http://www.w3.org/ns/oa#motivatedBy> <http://www.w3.org/ns/oa#commenting> .

    def post_annotation(oa)
      response = @site["/annotations/new"].post oa.to_jsonld, :content_type => :json
      # TODO: check response.code
      # TODO: add retry block?
      # TODO: log.debug on success; log.error on errors
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

