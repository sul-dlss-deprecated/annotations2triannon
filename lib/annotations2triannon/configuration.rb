
module Annotations2triannon

  class Configuration

    attr_reader :log_file
    attr_reader :log_path
    attr_reader :logger

    attr_accessor :debug
    attr_accessor :limit_random
    attr_accessor :limit_manifests
    attr_accessor :limit_annolists
    attr_accessor :limit_openannos

    attr_accessor :redis

    def initialize
      @debug = env_boolean('DEBUG')
      logger_init

      # In development, enable options for sampling the data
      @limit_random = env_boolean('ANNO_LIMIT_RANDOM') # 0..limit or random sampling
      @limit_manifests = ENV['ANNO_LIMIT_MANIFESTS'].to_i # 0 disables sampling
      @limit_annolists = ENV['ANNO_LIMIT_ANNOLISTS'].to_i # 0 disables sampling
      @limit_openannos = ENV['ANNO_LIMIT_OPENANNOS'].to_i # 0 disables sampling

      # Persistence options (TODO: provide options for triple stores)
      redis_init
    end

    # Utility method for sampling annotation arrays, using either linear or
    # random sampling of a subset of elements.  The instance variable
    # .limit_random is a configuration parameter that defines whether
    # linear or random sampling is used.
    # @param array [Array] An array to be sampled
    # @param limit [Integer] The number of elements to sample
    # @returns array [Array] A subset of the input array
    def array_sampler(array, limit=0)
      if limit > 0
        if @limit_random
          array.sample(limit)
        else
          limit = limit - 1
          array[0..limit]
        end
      else
        array
      end
    end


    private

    def env_boolean(var)
      # check if an ENV variable is true, use false as default
      ENV[var].to_s.upcase == 'TRUE' rescue false
    end

    def logger_init
      log_file = ENV['ANNO_LOG_FILE'] || 'annotations2triannon.log'
      log_file = File.absolute_path log_file
      @log_file = log_file
      @log_path = File.dirname log_file
      unless File.directory? @log_path
        # try to create the log directory
        Dir.mkdir @log_path rescue nil
      end
      begin
        log_dev = File.new(@log_file, 'w+')
      rescue
        log_dev = $stderr
        @log_file = 'STDERR'
      end
      log_dev.sync = true if @debug # skip IO buffering in debug mode
      @logger = Logger.new(log_dev, 'monthly')
      @logger.level = @debug ? Logger::DEBUG : Logger::INFO
    end

    def redis_init
      # https://github.com/redis/redis-rb
      # storing objects in redis:
      #redis.set "foo", [1, 2, 3].to_json
      #JSON.parse(redis.get("foo"))
      @redis = nil
      @redis_url = nil
      redis_enabled = env_boolean('REDIS_ENABLED')
      if redis_enabled
        @redis_url = ENV['REDIS_URL']
        require 'hiredis'
        require 'redis'
        if @redis_url
          # redis url takes the form "redis://{user}:{password}@{host}:{port}/{db}"
          @redis = Redis.new(:url => @redis_url)
          @redis.ping || puts('failed to init redis')
        else
          # default is 'redis://127.0.0.1:6379/0'
          @redis = Redis.new
          @redis.ping || puts('failed to init redis')
        end
      end
    end

  end

end

