module Parsers

  class MsrpParser < AmountParser
    MODEL = Expenditure

    def self.csvfields
      {
        :plan_id => 'PLANID',
        :year => 'PLANNINGYEAR',
        :goal_id => 'RFGOALID',
        :problem_objective_id => 'RFPROBLEMOBJECTIVEID',
        :output_id => 'RFOUTPUTID',
        :ppg_id => 'POPULATIONGROUPID',
        :budget_type => lambda do |row|
          raw_budget_type = row['BUDGET_TYPE']

          if raw_budget_type == 'UNHCR_ADMIN'
            return ADMIN
          elsif raw_budget_type == 'UNHCR_PROJECT'
            return PROJECT
          elsif raw_budget_type == 'UNHCR_STAFF'
            return STAFF
          elsif raw_budget_type == 'PARTNER_PROJECT'
            return PARTNER
          end
        end,
        :scenario => lambda do |row|
          raw_scenario = row['BUDGETCOMPONENT']
          if raw_scenario == 'BC-1'
            return OL
          elsif raw_scenario == 'BC-2'
            return AOL
          end
        end,
        :operation_id => 'OPERATIONID',
        :amount => 'AMOUNT'
      }

    end

  end
end
