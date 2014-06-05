module Parsers
  class PositionsParser < Parser
    def self.csvfields
      @csvfields ||= {
        :id => 'PLANNEDPOSITIONID',
        :grade => 'POSITIONGRADE',
        :title => 'POSITIONTITLE',
        :incumbent => 'INCUMBENT_NAME',
        :office_id => 'OFFICEID',
        :existing => lambda { |row| row['EXISTINGPOSITION'] == 'Y' },
        :contract_type => 'POSITIONTYPE',
        :parent_position_id => 'REPORTSTO_ID',
        :plan_id => 'PLANID',
        :operation_id => 'OPERATIONID'
      }
    end

    def parse(csv_filename)
      csvfields = PositionsParser.csvfields

      csv_foreach(csv_filename) do |row|
        next if row.empty?
        id = row[csvfields[:id]]

        (position = Position.find_or_initialize_by_id(:id => id).tap do |d|
          csvfields.each do |rails_attr, csvfield_attr|
            # If it's a lambda, call it
            if csvfield_attr.respond_to? :call
              d[rails_attr] = instance_exec row, &csvfield_attr
            else
              d[rails_attr] = row[csvfield_attr]
            end
          end
        end).save

        position.found
      end
    end
  end
end
