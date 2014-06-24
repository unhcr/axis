module Parsers
  class IndicatorDataParser < Parser

    MODEL = IndicatorDatum

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

  end
end
