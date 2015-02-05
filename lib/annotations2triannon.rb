require 'dotenv'
Dotenv.load

require 'pry'
require 'pry-doc'

require 'json'
require 'linkeddata'
require 'ruby-progressbar'

require_relative 'annotations2triannon/configuration'


module Annotations2triannon

  # configuration at the module level, see
  # http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.http_head_request(url)
    uri = URI.parse(url)
    begin
      if RUBY_VERSION =~ /^1\.9/
        req = Net::HTTP::Head.new(uri.path)
      else
        req = Net::HTTP::Head.new(uri)
      end
      Net::HTTP.start(uri.host, uri.port) {|http| http.request req }
    rescue
      @configuration.logger.error "Net::HTTP::Head failed for #{uri}"
      begin
        Net::HTTP.get_response(uri)
      rescue
        @configuration.logger.error "Net::HTTP.get_response failed for #{uri}"
        nil
      end
    end
  end

end

