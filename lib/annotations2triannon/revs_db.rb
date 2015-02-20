require 'logger'
require 'mysql2'
require 'sequel'
# An interface to the revs SQL database using Sequel
# @see http://sequel.jeremyevans.net/documentation.html Sequel RDoc
# @see http://sequel.jeremyevans.net/rdoc/files/README_rdoc.html Sequel README
# @see http://sequel.jeremyevans.net/rdoc/files/doc/code_order_rdoc.html Sequel code order

module Annotations2triannon

  class RevsDb

    @@log = Logger.new('log/revs_db.log')

    attr_accessor :db
    attr_accessor :db_config

    def self.log_model_info(m)
      @@log.info "table: #{m.table_name}, columns: #{m.columns}, pk: #{m.primary_key}"
    end

    def initialize
      @db_config = {}
      @db_config['host'] = ENV['REVS_DB_HOST'] || 'localhost'
      @db_config['port'] = ENV['REVS_DB_PORT'] || '3306'
      @db_config['user'] = ENV['REVS_DB_USER'] || 'revs'
      @db_config['password'] = ENV['REVS_DB_PASS'] || ''
      @db_config['database'] = ENV['REVS_DB_DATABASE'] || 'revs'
      options = @db_config.merge(
          {
              :encoding => 'utf8',
              :max_connections => 10,
              :logger => @@log
          })
      @db = Sequel.mysql2(options)
      @db.extension(:pagination)
      # Ensure the connection is good on startup, raises exceptions on failure
      @@log.info "#{@db} connected: #{@db.test_connection}"
    end

    def annotation(id)
      @db[:annotations][:id => id]
    end

    def annotations
      @db[:annotations]
    end

    def annotation_ids
      @db[:annotations].order(:user_id).select(:user_id, :id)
    end

    def annotations_join_users
      @db[:annotations].join_table(:inner, @db[:users], :id=>:user_id)
      # @db[:annotations].join_table(:outer, @db[:users], :id=>:user_id)
    end

    def users
      @db[:users]
    end

    def user(id)
      @db[:users][:id => id]
    end

  end

end

