module MassInsert
  module Adapters
    class ColumnValue < Adapter

      attr_accessor :row, :column, :options

      def initialize row, column, options
        @row     = row
        @column  = column
        @options = options
      end

      # Returns a symbol with the column type in the database. The column or
      # attribute should belongs to the class that invokes the mass insert.
      def column_type
        class_name.columns_hash[@column.to_s].type
      end

      def column_value
        row[column.to_sym]
      end

      # Returns a single column string value with the correct format and
      # according to the database configuration, column type and presence.
      def build
        case column_type
        when :string, :text, :date, :datetime, :time, :timestamp
          "'#{column_value}'"
        when :integer
          column_value.to_i.to_s
        when :decimal, :float
          column_value.to_f.to_s
        when :boolean, :binary
          column_value ? 1 : 0
        end
      end

    end
  end
end