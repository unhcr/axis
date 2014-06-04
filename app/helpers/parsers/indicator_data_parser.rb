module Parsers
  class IndicatorDataParser < Parser

    PRIORITIES = {
      :partial => 'Partially prioritized',
      :fully => 'Fully prioritized',
      :not => 'Not prioritized'
    }

    EXCLUDED = 'Excluded'

    def self.csvfields
      @csvfields = {
        :plan_id => 'PLANID',
        :year => 'PLANNINGYEAR',
        :operation_id => 'OPERATIONID',
        :ppg_id => 'PPGID',
        :goal_id => 'RFGOALID',
        :rights_group_id => 'RFRIGHTSGROUPID',
        :problem_objective_id => 'RFPROBLEMOBJECTIVEID',
        :priority => 'PRIORITY',
        :indicator_type => 'INDICATOR_TYPE',
        :reversal => lambda { |row| row['REVERSAL'].to_i == 1 },
        :missing_budget => lambda do |row|
            priority = row['PRIORITY']
            priority == PRIORITIES[:not]
          end,
        :excluded => lambda { |row| row['EXCLUDED'] == EXCLUDED }
      }

    end

    def indicator_value_parse(row, field)
      row[field] == NULL ? nil : row[field]
    end

    def parse(csv_filename)

      csvfields = self.class.csvfields

      csv_foreach(csv_filename) do |row|
        next if row.empty?
        id = row[csvfields[:id]]

        (datum = IndicatorDatum.find_or_initialize_by_id(:id => id).tap do |d|
          csvfields.each do |rails_attr, csvfield_attr|
            # If it's a lambda, call it
            if csvfield_attr.respond_to? :call
              d[rails_attr] = instance_exec row, &csvfield_attr
            else
              d[rails_attr] = row[csvfield_attr]
            end
          end
        end).save

        datum.found
      end

    end
  end
end
