require_relative 'returning_attributes/patching'
require_relative 'returning_attributes/version'

require 'active_support/lazy_load_hooks'

module ActiveRecord
  module ReturningAttributes
    def self.postgresql_only
      if postgresql?
        yield
      else
        warn 'ActiveRecord::ReturningAttributes only works with PostgreSQL, skipping patching ActiveRecord.'
      end
    end

    def self.postgresql?
      begin
        require 'pg'
        true
      rescue LoadError
        false
      end
    end

    def self.active_record_7_0_tested_only
      unless ActiveRecord.version >= '7.0.0' && ActiveRecord.version < '7.1'
        warn 'ActiveRecord::ReturningAttributes was only tested on ActiveRecord 7.0.x and might not work with your version.'
      end
    end


    ActiveSupport.on_load(:active_record) do
      ReturningAttributes.postgresql_only do
        ReturningAttributes::Patching.patch_base
        ReturningAttributes::Patching.patch_persistence
        ReturningAttributes::Patching.patch_database_statements
        ReturningAttributes::Patching.patch_postgresql_database_statements
        ReturningAttributes::Patching.patch_postgresql_adapter

        ReturningAttributes.active_record_7_0_tested_only
      end
    end
  end
end
