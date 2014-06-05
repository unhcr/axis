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
  end
end
