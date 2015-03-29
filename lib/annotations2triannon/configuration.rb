
module Annotations2triannon

  class Configuration

    attr_reader :log_file
    attr_reader :log_path
    attr_reader :logger

    attr_accessor :debug
    attr_accessor :limit_manifests
    attr_accessor :limit_annolists
    attr_accessor :limit_openannos

    def initialize
      @debug = env_boolean('DEBUG')

      # In development, enable options for random sampling the data
      @limit_manifests = ENV['ANNO_LIMIT_MANIFESTS'].to_i  # 0 disables sampling
      @limit_annolists = ENV['ANNO_LIMIT_ANNOLISTS'].to_i  # 0 disables sampling
      @limit_openannos = ENV['ANNO_LIMIT_OPENANNOS'].to_i  # 0 disables sampling

      # logger
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

    def env_boolean(var)
      # check if an ENV variable is true, use false as default
      ENV[var].to_s.upcase == 'TRUE' rescue false
    end

  end

end

