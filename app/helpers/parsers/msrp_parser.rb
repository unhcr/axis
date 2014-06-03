module Parsers

  class MsrpParser < Parser
    require "csv"
    AOL = 'Above Operating Level'
    OL = 'Operating Level'

    ADMIN = 'ADMIN'
    PARTNER = 'PARTNER'
    PROJECT = 'PROJECT'
    STAFF = 'STAFF'

    def self.fields
      {
        :plan_id => 'PLANID',
        :year => 'PLANNINGYEAR',
        :goal_id => 'RFGOALID',
        :problem_objective_id => 'RFPROBLEMOBJECTIVEID',
        :output_id => 'RFOUTPUTID',
        :ppg_id => 'POPULATIONGROUPID',
        :budget_type => 'BUDGET_TYPE',
        :scenario => 'BUDGETCOMPONENT',
        :operation_id => 'OPERATIONID',
        :amount => 'AMOUNT'
      }

    end

    def parse(csv_filename)

      fields = MsrpParser.fields

      CSV.foreach(csv_filename, :headers => true, :col_sep => COL_SEP) do |row|
        next if row.empty?

        attrs = {
          :plan_id => row[fields[:plan_id]],
          :operation_id => row[fields[:operation_id]],
          :ppg_id => row[fields[:ppg_id]],
          :goal_id => row[fields[:goal_id]],
          :problem_objective_id => row[fields[:problem_objective_id]],
          :output_id => row[fields[:output_id]],
          :year => row[fields[:year]],
        }

        raw_budget_type = row[fields[:budget_type]]
        raw_scenario = row[fields[:scenario]]

        if raw_budget_type == 'UNHCR_ADMIN'
          attrs[:budget_type] = ADMIN
        elsif raw_budget_type == 'UNHCR_PROJECT'
          attrs[:budget_type] = PROJECT
        elsif raw_budget_type == 'UNHCR_STAFF'
          attrs[:budget_type] = STAFF
        elsif raw_budget_type == 'PARTNER_PROJECT'
          attrs[:budget_type] = PARTNER
        end


        if raw_scenario == 'BC-1'
          attrs[:scenario] = OL
        elsif raw_scenario == 'BC-2'
          attrs[:scenario] = AOL
        end

        e = Expenditure.where(attrs).first
        if e
          e.amount = row[fields[:amount]]
          e.save
          e.found
        else
          e = Expenditure.new(attrs)
          e.amount = row[fields[:amount]]
          e.save
        end
      end

    end
  end
end
