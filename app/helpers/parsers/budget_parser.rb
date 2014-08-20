module Parsers
  class BudgetParser < AmountParser
    MODEL = Budget

    def self.csvfields
      @csvfields ||= {
        :plan_id => 'PLANID',
        :year => 'PLANNINGYEAR',
        :goal_id => 'RFGOALID',
        :problem_objective_id => 'RFPROBLEMOBJECTIVEID',
        :output_id => 'RFOUTPUTID',
        :ppg_id => 'PPGID',
        :pillar => 'POPGROUPTYPEID',
        :budget_type => lambda do |row|
          raw_budget_type = row['BUDGETTYPE']

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
        :scenario => 'BUDGETCOMPONENT',
        :operation_id => 'OPERATIONID',
        :amount => 'AMOUNT'
      }

    end

  end
end
