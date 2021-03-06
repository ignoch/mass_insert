module MassInsert
  module Builder
    module Adapters
      class Adapter
        include Helpers::AbstractQuery

        attr_accessor :values, :options

        def initialize values, options
          @values  = values
          @options = options
        end

        # Returns the options according to the method that wasn't found.
        def method_missing method, *args
          @options.has_key?(method) ? @options[method] : super
        end

        # Returns an array according to the options with the column names
        # that will be included in the queries.
        def columns
          @columns ||= sanitized_columns
        end

        # Prepare array with the column names according to the options.
        def sanitized_columns
          columns = class_name.column_names
          columns.delete(class_name.primary_key) unless primary_key
          columns.map(&:to_sym)
        end

        # Returns true o false if the database table has timestamp columns.
        def timestamp?
          columns.include?(:created_at) && columns.include?(:updated_at)
        end

        # Returns timestamp format according to the database adapter. This
        # function can be overwrite in database adapters classes.
        def timestamp_format
          "%Y-%m-%d %H:%M:%S.%6N"
        end

        # Returns the timestamp value according to the correct timestamp
        # format to that database engine.
        def timestamp
          Time.now.strftime(timestamp_format)
        end

        # Returns the timestamp hash to be merge into row values that will
        # be saved in the database.
        def timestamp_hash
          timestamp_value = timestamp
          {:created_at => timestamp_value, :updated_at => timestamp_value}
        end

        # Returns the amount of records to each query. Tries to take the
        # each_slice option value or the length of values.
        def values_per_insertion
          each_slice || @values.count
        end

      end
    end
  end
end
