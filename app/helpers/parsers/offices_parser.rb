module Parsers
  class OfficesParser < Parser
    def self.csvfields
      @csvfields ||= {
        :id => 'PRJOFFICEID',
        :status => 'STATUS',
        :name => 'OFFICENAME',
        :parent_office_id => 'PARENTOFFICEID',
        :plan_id => 'OPERATIONPLAN_ID',
        :operation_id => 'OPERATIONID'
      }
    end

    def parse(csv_filename)
      csvfields = OfficesParser.csvfields

      csv_foreach(csv_filename) do |row|
        next if row.empty?
        id = row[csvfields[:id]]

        (office = Office.find_or_initialize_by_id(:id => id).tap do |d|
          csvfields.each do |rails_attr, csvfield_attr|
            # If it's a lambda, call it
            if csvfield_attr.respond_to? :call
              d[rails_attr] = instance_exec row, &csvfield_attr
            else
              d[rails_attr] = row[csvfield_attr]
            end
          end
        end).save

        office.found
      end
    end
  end
end

