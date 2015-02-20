
module Annotations2triannon

  class Configuration

    attr_accessor :debug
    attr_accessor :logger

    def initialize
      @debug = env_boolean('DEBUG')

      # logger
      log_file = ENV['LOG_FILE'] || 'annotations2triannon.log'
      log_file = File.absolute_path log_file
      @log_file = log_file
      log_path = File.dirname log_file
      unless File.directory? log_path
        # try to create the log directory
        Dir.mkdir log_path rescue nil
      end
      begin
        log_file = File.new(@log_file, 'w+')
      rescue
        log_file = $stderr
        @log_file = 'STDERR'
      end
      @logger = Logger.new(log_file, shift_age = 'monthly')
      @logger.level = @debug ? Logger::DEBUG : Logger::INFO

    end

    def env_boolean(var)
      # check if an ENV variable is true, use false as default
      ENV[var].to_s.upcase == 'TRUE' rescue false
    end

  end

end

