module Parsers
  # Abstract class
  class Parser
    require "csv"

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

      columns = csvfields.keys
      columns << :found_at
      values = []

      csv_foreach(csv_filename) do |row|
        next if row.empty?

        element = csv_parse_element csvfields, row

        values << element
      end

      to_update = columns.dup
      to_update.delete :id

      self.class::MODEL.import columns, values, :on_duplicate_key_update => to_update
    end

    def csv_parse_element(csvfields, row)
      element = []

      csvfields.each do |rails_attr, csvfield_attr|
        # If it's a lambda, call it
        if csvfield_attr.respond_to? :call
          element << instance_exec(row, &csvfield_attr)
        else
          element << row[csvfield_attr]
        end
      end

      # Add found_at parameter
      element << Time.now

      element
    end
  end
end
