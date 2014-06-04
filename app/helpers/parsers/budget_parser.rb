module Parsers
  class BudgetParser < Parser
    AOL = 'Above Operating Level'
    OL = 'Operating Level'

    ADMIN = 'ADMIN'
    PARTNER = 'PARTNER'
    PROJECT = 'PROJECT'
    STAFF = 'STAFF'

    def self.csvfields
      @fields ||= {
        :plan_id => 'PLANID',
        :year => 'PLANNINGYEAR',
        :goal_id => 'RFGOALID',
        :problem_objective_id => 'RFPROBLEMOBJECTIVEID',
        :output_id => 'RFOUTPUTID',
        :ppg_id => 'PPGID',
        :budget_type => 'BUDGETTYPE',
        :scenario => 'BUDGETCOMPONENT',
        :operation_id => 'OPERATIONID',
        :amount => 'AMOUNT'
      }

    end

    def parse(csv_filename)

      csvfields = BudgetParser.csvfields

      csv_foreach(csv_filename) do |row|
        next if row.empty?

        attrs = {
          :plan_id => row[csvfields[:plan_id]],
          :operation_id => row[csvfields[:operation_id]],
          :ppg_id => row[csvfields[:ppg_id]],
          :goal_id => row[csvfields[:goal_id]],
          :problem_objective_id => row[csvfields[:problem_objective_id]],
          :output_id => row[csvfields[:output_id]],
          :year => row[csvfields[:year]],
          :scenario => row[csvfields[:scenario]]
        }

        raw_budget_type = row[csvfields[:budget_type]]

        if raw_budget_type == 'UNHCR_ADMIN'
          attrs[:budget_type] = ADMIN
        elsif raw_budget_type == 'UNHCR_PROJECT'
          attrs[:budget_type] = PROJECT
        elsif raw_budget_type == 'UNHCR_STAFF'
          attrs[:budget_type] = STAFF
        elsif raw_budget_type == 'PARTNER_PROJECT'
          attrs[:budget_type] = PARTNER
        end


        e = Budget.where(attrs).first
        if e
          e.amount = row[csvfields[:amount]]
          e.save
          e.found
        else
          e = Budget.new(attrs)
          e.amount = row[csvfields[:amount]]
          e.save
        end
      end

    end
  end
end
