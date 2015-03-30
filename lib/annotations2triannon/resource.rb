
module Annotations2triannon

  class Resource

    @@config = nil

    def self.http_head_request(url)
      uri = nil
      begin
        response = RestClient.head(url)
        uri = response.args[:url]
      rescue
        @@config.logger.error "RestClient.head failed for #{url}"
        begin
          response = RestClient.get(url)
          uri = response.args[:url]
        rescue
          @@config.logger.error "RestClient.get failed for #{url}"
        end
      end
      uri
    end

    attr_accessor :iri

    def initialize(uri=nil)
      @@agent ||= Annotations2triannon::AGENT
      @@config ||= Annotations2triannon.configuration
      if uri =~ /\A#{URI::regexp}\z/
        uri = Addressable::URI.parse(uri.to_s) rescue nil
      end
      raise 'invalid uri' unless uri.instance_of? Addressable::URI
      @iri = uri
    end

    def id
      @iri.basename
    end

    def iri_type?(type)
      iri_types.include? RDF::URI.parse(type)
    end

    def iri_types
      q = [rdf_uri, RDF.type, :o]
      rdf.query(q).collect {|s| s.object }
    end

    # Assert PROV.SoftwareAgent and PROV.generatedAtTime
    def provenance
      s = [rdf_uri, RDF::PROV.SoftwareAgent, @@agent]
      rdf.insert(s)
      s = [rdf_uri, RDF::PROV.generatedAtTime, rdf_now]
      rdf.insert(s)
    end

    # This method is often overloaded in subclasses because
    # RDF services use variations in the URL 'extension' patterns; e.g.
    # see Loc#rdf and Viaf#rdf
    def rdf
      # TODO: try to retrieve the rdf from a local triple store
      # TODO: if local triple store fails, try remote source(s)
      # TODO: if retrieved from a remote source, save the rdf to a local triple store
      return @rdf unless @rdf.nil?
      uri4rdf = @iri.to_s
      tries = 0
      begin
        tries += 1
        @rdf = RDF::Graph.load(uri4rdf)
      rescue
        sleep 1*tries
        retry if tries < 3
        binding.pry if @@config.debug
        @@config.logger.error("Failed to retrieve RDF for #{uri4rdf}")
        @rdf = nil
      end
    end

    # RDF query to find all objects of a predicate
    # @param predicate [RDF::URI] An RDF predicate, the ?p in ?s ?p ?o
    # @return [Array] The objects of predicate, the ?o in ?s ?p ?o
    def query_predicate_objects(predicate)
      q = [:s, predicate, :o]
      rdf.query(q).collect {|s| s.object }
    end

    # RDF query to find all subjects with a predicate
    # @param predicate [RDF::URI] An RDF predicate, the ?p in ?s ?p ?o
    # @return [Array] The subjects with predicate, the ?s in ?s ?p ?o
    def query_predicate_subjects(predicate)
      q = [:s, predicate, :o]
      rdf.query(q).collect {|s| s.subject }
    end

    # Regexp search to find an object matching a string, if it belongs to @iri
    # @param id [String] A string literal used to construct a Regexp
    # @return [RDF::URI] The first object matching the Regexp
    def rdf_find_object(id)
      return nil unless rdf_valid?
      rdf.each_statement do |s|
        if s.subject == @iri.to_s
          return s.object if s.object.to_s =~ Regexp.new(id, Regexp::IGNORECASE)
        end
      end
      nil
    end

    # Regexp search to find a subject matching a string
    # @param id [String] A string literal used to construct a Regexp
    # @return [RDF::URI] The first subject matching the Regexp
    def rdf_find_subject(id)
      return nil unless rdf_valid?
      rdf.each_subject do |s|
        return s if s.to_s =~ Regexp.new(id, Regexp::IGNORECASE)
      end
      nil
    end

    # @param object [RDF::Node] An RDF blank node
    # @return [RDF::Graph] graph of recursive resolution for a blank node
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

    # ----
    # RDF::Graph convenience wrappers

    def rdf_insert(uriS, uriP, uriO)
      @rdf.insert RDF::Statement(uriS, uriP, uriO)
    end
    def rdf_insert_sameAs(uriS, uriO)
      rdf_insert(uriS, RDF::OWL.sameAs, uriO)
    end
    def rdf_insert_seeAlso(uriS, uriO)
      rdf_insert(uriS, RDF::RDFS.seeAlso, uriO)
    end
    def rdf_insert_creator(uriS, uriO)
      rdf_insert(uriS, RDF::SCHEMA.creator, uriO)
    end
    def rdf_insert_contributor(uriS, uriO)
      rdf_insert(uriS, RDF::SCHEMA.contributor, uriO)
    end
    def rdf_insert_editor(uriS, uriO)
      rdf_insert(uriS, RDF::SCHEMA.editor, uriO)
    end
    def rdf_insert_exampleOfWork(uriS, uriO)
      rdf_insert(uriS, RDF::SCHEMA.exampleOfWork, uriO)
    end
    def rdf_insert_foafFocus(uriS, uriO)
      # http://xmlns.com/foaf/spec/#term_focus
      # relates SKOS:Concept to a 'real world thing'
      rdf_insert(uriS, RDF::FOAF.focus, uriO)
    end
    def rdf_insert_name(uriS, name)
      rdf_insert(uriS, RDF::FOAF.name, name) if @@config.use_foaf
      rdf_insert(uriS, RDF::SCHEMA.name, name) if @@config.use_schema
    end

    def rdf_now
      RDF::Literal.new(Time.now.utc, :datatype => RDF::XSD.dateTime)
    end

    def rdf_uri
      RDF::URI.new(@iri)
    end

    # Methods that assert RDF.type

    def rdf_insert_type(uriS, uriO)
      rdf_insert(uriS, RDF.type, uriO)
    end

    def rdf_type_agent(uriS)
      # Note: schema.org has no immediate parent for Person or Organization
      rdf_insert_type(uriS, RDF::FOAF.Agent) if @@config.use_foaf
      rdf_insert_type(uriS, RDF::SCHEMA.Thing) if @@config.use_schema
    end

    def rdf_type_concept(uriS)
      rdf_insert_type(uriS, RDF::SKOS.Concept)
    end

    def rdf_type_organization(uriS)
      rdf_insert_type(uriS, RDF::FOAF.Organization) if @@config.use_foaf
      rdf_insert_type(uriS, RDF::SCHEMA.Organization) if @@config.use_schema
    end

    def rdf_type_person(uriS)
      rdf_insert_type(uriS, RDF::FOAF.Person) if @@config.use_foaf
      rdf_insert_type(uriS, RDF::SCHEMA.Person) if @@config.use_schema
    end

    def rdf_valid?
      iri_types.length > 0
    end



    # ---
    # HTTP methods

    # @param url [String|URI] A URL that can be resolved via HTTP request
    # @return [String] The URL that resolves, after permanent redirections
    def resolve_url(url)
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

    def same_as_org_graph
      return @same_as_org_graph unless @same_as_org_graph.nil?
      same_as_url = 'http://sameas.org/rdf?uri=' + URI.encode(@iri.to_s)
      @same_as_org_graph = RDF::Graph.load(same_as_url)
    end
    def same_as_org_query
      # q = SPARQL.parse("SELECT * WHERE { <#{@iri}> <http://www.w3.org/2002/07/owl#sameAs> ?o }")
      q = [rdf_uri, RDF::OWL.sameAs, nil]
      same_as_org_graph.query(q).collect {|s| s.object }
    end



    # ---
    # Transforms or Serialization

    # A json-ld object for the rdf resource
    def as_jsonld
      JSON::LD::API::fromRdf(rdf)
    end

    # A json-ld serialization of the rdf resource
    def to_jsonld
      rdf.dump(:jsonld, standard_prefixes: true)
    end

    # A turtle serialization of the rdf resource
    def to_ttl
      rdf.dump(:ttl, standard_prefixes: true)
    end

  end

end


