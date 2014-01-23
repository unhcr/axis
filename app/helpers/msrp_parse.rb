module MsrpParse
  require "csv"
  AOL = 'Above Operating Level'
  OL = 'Operating Level'

  ADMIN = 'ADMIN'
  PARTNER = 'PARTNER'
  PROJECT = 'PROJECT'
  STAFF = 'STAFF'

  def parse(csv_filename)

    CSV.foreach(csv_filename, :headers => true) do |row|

      attrs = {
        :plan_id => row['planid'],
        :ppg_id => row['populationgroupid'],
        :goal_id => row['goalid'],
        :problem_objective_id => row['objectiveid'],
        :output_id => row['outputid'],
        :year => row['planningyear'],
      }

      raw_budget_type = row['budget_type']
      raw_scenario = row['budgetcomponent']

      attrs[:budget_type]

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
        e.amount = row['amount']
        e.save
        e.found
      else
        Expenditure.create(attrs)
      end
    end

  end
end
