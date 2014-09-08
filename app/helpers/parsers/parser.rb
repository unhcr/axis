module Parsers
  # Abstract class
  class Parser
    require "csv"
    require 'upsert/active_record_upsert'

    NULL = "null"
    COL_SEP = '###'

    def replace_nulls(row)
      row.each { |key, value| row[key] = nil if row[key] == NULL }
    end

    def csv_foreach(csv_filename, &block)
      begin
        CSV.foreach(csv_filename, :headers => true, :col_sep => COL_SEP) do |row|
          mapped = replace_nulls row
          block.call(mapped)
        end
      rescue Exception => e
        p "Unable to parse for #{csv_filename}"
        p e.message
        p e.backtrace.inspect
        exit 1
      end
    end

    def parse(csv_filename)

      csvfields = self.class.csvfields

      model = self.class::MODEL

      Upsert.batch(ActiveRecord::Base.connection, model.table_name.to_sym) do |upsert|
        csv_foreach(csv_filename) do |row|
          next if row.empty?

          element = csv_parse_element csvfields, row

          selector = element.dup
          selector.keep_if { |k, v| self.class.selector.include? k }

          setter = element.dup
          setter.keep_if { |k, v| !self.class.selector.include?(k) }

          next if selector.has_key?(:id) && selector[:id].nil?
          upsert.row selector, setter
        end
      end
    end

    def csv_parse_element(csvfields, row)
      element = {}

      csvfields.each do |rails_attr, csvfield_attr|
        # If it's a lambda, call it
        if csvfield_attr.respond_to? :call
          element[rails_attr] = instance_exec(row, &csvfield_attr)
        else
          element[rails_attr] = row[csvfield_attr]
        end
      end

      # Add *_at parameters
      element[:found_at] = Time.now
      element[:created_at] = Time.now
      element[:updated_at] = Time.now

      element
    end
  end

end
