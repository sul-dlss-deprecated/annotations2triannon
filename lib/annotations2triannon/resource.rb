
module Annotations2triannon

  class Resource

    @@config = nil

    # def self.http_head_request(url)
    #   uri = URI.parse(url)
    #   begin
    #     if RUBY_VERSION =~ /^1\.9/
    #       req = Net::HTTP::Head.new(uri.path)
    #     else
    #       req = Net::HTTP::Head.new(uri)
    #     end
    #     Net::HTTP.start(uri.host, uri.port) {|http| http.request req }
    #   rescue
    #     @config.logger.error "Net::HTTP::Head failed for #{uri}"
    #     begin
    #       Net::HTTP.get_response(uri)
    #     rescue
    #       @config.logger.error "Net::HTTP.get_response failed for #{uri}"
    #       nil
    #     end
    #   end
    # end

    def self.http_head_request(url)
      uri = nil
      begin
        response = RestClient.head(url)
        uri = response.args[:url]
      rescue
        @configuration.logger.error "RestClient.head failed for #{url}"
        begin
          response = RestClient.get(url)
          uri = response.args[:url]
        rescue
          @configuration.logger.error "RestClient.get failed for #{url}"
        end
      end
      uri
    end


    attr_accessor :iri
    # attr_reader :config

    def initialize(uri=nil)
      @@config ||= Annotations2triannon.configuration
      if uri =~ /\A#{URI::regexp}\z/
        uri = Addressable::URI.parse(uri.to_s) rescue nil
      end
      # Strip off any trailing '/'
      if uri.to_s.end_with? '/'
        uri = uri.to_s.gsub(/\/$/,'')
        uri = Addressable::URI.parse(uri.to_s) rescue nil
      end
      raise 'invalid uri' unless uri.instance_of? Addressable::URI
      @iri = uri
    end

    def id
      @iri.basename
    end

    # This method is often overloaded in subclasses because
    # RDF services use variations in the URL 'extension' patterns; e.g.
    # see Loc#rdf and Viaf#rdf
    def rdf
      return @rdf unless @rdf.nil?
      # TODO: try to retrieve the rdf from a local triple store
      # TODO: if local triple store fails, try remote source(s)
      # TODO: if retrieved from a remote source, save the rdf to a local triple store
      @rdf = get_rdf(@iri.to_s)
    end

    def get_rdf(uri4rdf)
      tries = 0
      begin
        tries += 1
        @rdf = RDF::Graph.load(uri4rdf)
      rescue
        retry if tries <= 2
        binding.pry if @@config.debug
        nil
      end
    end

    def rdf_uri
      RDF::URI.new(@iri)
    end

    def rdf_valid?
      iri_types.length > 0
    end

    def iri_types
      q = SPARQL.parse("SELECT * WHERE { <#{@iri}> a ?o }")
      rdf.query(q)
    end

    def rdf_find_object(id)
      # TODO: convert this to an RDF.rb graph query?
      return nil unless rdf_valid?
      rdf.each_statement do |s|
        if s.subject == @iri.to_s
          return s.object if s.object.to_s =~ Regexp.new(id, Regexp::IGNORECASE)
        end
      end
      nil
    end

    def rdf_find_subject(id)
      # TODO: convert this to an RDF.rb graph query?
      return nil unless rdf_valid?
      rdf.each_subject do |s|
        return s if s.to_s =~ Regexp.new(id, Regexp::IGNORECASE)
      end
      nil
    end

    def rdf_expand_blank_nodes(object)
      g = RDF::Graph.new
      if object.node?
        rdf.query([object, nil, nil]) do |s,p,o|
          g << [s,p,o]
          g << rdf_expand_blank_nodes(o) if o.node?
        end
      end
      g
    end

    def resolve_external_auth(url)
      begin
        # RestClient does all the response code handling and redirection.
        url = Resource.http_head_request(url)
        if url.nil?
          @@config.logger.warn "#{@iri}\t// #{url}"
        else
          @@config.logger.debug "Mapped #{@iri}\t-> #{url}"
        end
      rescue
        binding.pry if @@config.debug
        @@config.logger.error "unknown http error for #{@iri}"
        url = nil
      end
      url
    end

    def same_as
      same_as_url = 'http://sameas.org/rdf?uri=' + URI.encode(@iri.to_s)
      RDF::Graph.load(same_as_url)
    end

    def same_as_array
      q = SPARQL.parse("SELECT * WHERE { <#{@iri}> <http://www.w3.org/2002/07/owl#sameAs> ?o }")
      same_as.query(q).collect {|s| s[:o] }
    end

    # A json-ld representation of the open annotation
    def as_jsonld
      JSON::LD::API::fromRdf(rdf)
    end

    # A json-ld string representation of the open annotation
    def to_jsonld
      rdf.dump(:jsonld, standard_prefixes: true)
    end

    # A turtle string representation of the open annotation
    def to_ttl
      rdf.dump(:ttl, standard_prefixes: true)
    end
  end

end


