module FocusParse
  PLAN = 'Plan'
  PROBLEM_OBJECTIVE = 'ProblemObjective'
  RIGHTS_GROUP = 'RightsGroup'
  GOAL = 'Goal'
  PPG = 'PPG'
  OUTPUT = 'Output'
  INDICATOR = 'Indicator'
  BUDGET_LINE = 'BudgetLine'
  OPERATION_HEADER = 'OperationHeader'

  AOL = 'Above Operating Level'
  OL = 'Operating Level'

  ADMIN = 'ADMIN'
  PARTNER = 'PARTNER'
  PROJECT = 'PROJECT'
  STAFF = 'STAFF'

  include CountryHelper

  def parse_header(file, plan_types = ['ONEPLAN'])
    doc = Nokogiri::XML(file)

    ret = {
      :ids => [],
      :operation_count => 0
    }

    plan_types.each do |type|
      ret[:ids] += doc.search("//PlanHeader[type =\"#{type}\"]/@ID").map(&:value)
    end

    xml_operation_headers = doc.search(OPERATION_HEADER)

    xml_operation_headers.each do |xml_operation_header|
      id = xml_operation_header.search('./operationID').text
      name = xml_operation_header.search('./name').text
      years = []


      plan_types.each do |type|
        years += xml_operation_header.search(
          "./plans/PlanHeader[type = \"#{type}\"]/planningPeriod").map(&:text)
      end

      Operation.find_or_initialize_by_id(:id => id).tap do |o|
        o.id = id
        o.name = name
        o.years = years.uniq
      end.save

    end

    return ret

  end

  def parse_plan(file)
    #TODO Update new data pts if they created new data
    doc = Nokogiri::XML(file)

    xml_plan = doc.search(PLAN)

    (plan = Plan.find_or_initialize_by_id(:id => xml_plan.attribute('ID').value).tap do |p|
      p.operation_name = xml_plan.search('./operation').text
      p.year = xml_plan.search('./year').text.to_i
      p.name = xml_plan.search('./name').text
      p.id = xml_plan.attribute('ID').value

    end).save

    unless plan.country
      match_plan_to_country(plan)
    end

    operation = Operation.find(xml_plan.search('./operationID').text)
    operation.plans << plan unless operation.plans.include? plan

    xml_ppgs = xml_plan.search(PPG)

    xml_ppgs.each do |xml_ppg|

      (ppg = Ppg.find_or_initialize_by_id(xml_ppg.attribute('POPGRPID').value).tap do |p|
        p.name = xml_ppg.search('./name').text
        p.id = xml_ppg.attribute('POPGRPID').value
        p.population_type = xml_ppg.search('./typeName').text
        p.population_type_id = xml_ppg.search('./typeID').text
        p.operation_name = operation.name
      end).save

      plan.ppgs << ppg unless plan.ppgs.include? ppg
      operation.ppgs << ppg unless operation.ppgs.include? ppg

      xml_goals = xml_ppg.search(GOAL)

      xml_goals.each do |xml_goal|
        xml_rights_groups = xml_goal.search(RIGHTS_GROUP)

        (goal = Goal.find_or_initialize_by_id(:id => xml_goal.attribute('RFID').value).tap do |g|
          g.name = xml_goal.search('./name').text
          g.id = xml_goal.attribute('RFID').value
        end).save

        ppg.goals << goal unless ppg.goals.include? goal
        operation.goals << goal unless operation.goals.include? goal
        plan.goals << goal unless plan.goals.include? goal

        xml_rights_groups.each do |xml_rights_group|
          xml_problem_objectives = xml_rights_group.search(PROBLEM_OBJECTIVE)

          (rights_group = RightsGroup.find_or_initialize_by_id(:id => xml_rights_group.attribute('RFID').value).tap do |rg|
            rg.name = xml_rights_group.search('./name').text
            rg.id = xml_rights_group.attribute('RFID').value
          end).save

          goal.rights_groups << rights_group unless goal.rights_groups.include? rights_group
          operation.rights_groups << rights_group unless operation.rights_groups.include? rights_group
          plan.rights_groups << rights_group unless plan.rights_groups.include? rights_group

          xml_problem_objectives.each do |xml_problem_objective|
            xml_outputs = xml_problem_objective.search(OUTPUT)

            (problem_objective = ProblemObjective.find_or_initialize_by_id(:id => xml_problem_objective.attribute('RFID').value).tap do |po|
              po.objective_name = xml_problem_objective.search('./objectiveName').text
              po.problem_name = xml_problem_objective.search('./problemName').text
              po.is_excluded = to_boolean(xml_problem_objective.search('./isExcluded').text)
              po.id = xml_problem_objective.attribute('RFID').value
            end).save

            unless rights_group.problem_objectives.include? problem_objective
              rights_group.problem_objectives << problem_objective
            end
            unless operation.problem_objectives.include? problem_objective
              operation.problem_objectives << problem_objective
            end
            unless plan.problem_objectives.include? problem_objective
              plan.problem_objectives << problem_objective
            end

            xml_outputs.each do |xml_output|
              # Must be performance indicators if part of output
              xml_performance_indicators = xml_output.search(INDICATOR)
              xml_budget_lines = xml_output.search(BUDGET_LINE)

              (output = Output.find_or_initialize_by_id(:id => xml_output.attribute('RFID').value).tap do |o|
                o.name = xml_output.search('./name').text
                o.priority = xml_output.search('./priority').text
                o.id = xml_output.attribute('RFID').value
              end).save

              problem_objective.outputs << output unless problem_objective.outputs.include? output
              operation.outputs << output unless operation.outputs.include? output
              plan.outputs << output unless plan.outputs.include? output

              xml_performance_indicators.each do |xml_performance_indicator|
                (indicator = Indicator.find_or_initialize_by_id(:id => xml_performance_indicator.attribute('RFID').value).tap do |i|
                  i.name = xml_performance_indicator.search('name').text
                  i.is_performance = to_boolean(xml_performance_indicator.search('isPerformance').text)
                  i.is_gsp = to_boolean(xml_performance_indicator.search('isGSP').text)
                  i.id = xml_performance_indicator.attribute('RFID').value
                end).save

                output.indicators << indicator unless output.indicators.include? indicator
                operation.indicators << indicator unless operation.indicators.include? indicator
                plan.indicators << indicator unless plan.indicators.include? indicator

                # Create datum
                IndicatorDatum.find_or_initialize_by_id(:id => xml_performance_indicator.attribute('ID').value).tap do |d|
                  d.id = xml_performance_indicator.attribute('ID').value
                  d.goal = goal
                  d.rights_group = rights_group
                  d.plan = plan
                  d.ppg = ppg
                  d.problem_objective = problem_objective
                  d.output = output
                  d.operation = operation
                  d.indicator = indicator
                  d.yer = xml_performance_indicator.search('./yearEndValue').text.to_i
                  d.myr = xml_performance_indicator.search('./midYearValue').text.to_i
                  d.standard = xml_performance_indicator.search('./standard').text.to_i
                  d.baseline = xml_performance_indicator.search('./baseline').text.to_i
                  d.comp_target = xml_performance_indicator.search('./compTarget').text.to_i
                  d.is_performance = true
                  d.year = plan.year
                end.save

              end

              xml_budget_lines.each do |xml_budget_line|

                scenario = xml_budget_line.search('./scenario').text
                amount = xml_budget_line.search('./amount').text.to_i
                type = xml_budget_line.search('./type').text

                if scenario == AOL
                  if type == ADMIN
                    output.aol_admin_budget += amount
                    problem_objective.aol_admin_budget += amount
                  elsif type == PARTNER
                    output.aol_partner_budget += amount
                    problem_objective.aol_partner_budget += amount
                  elsif type == PROJECT
                    output.aol_project_budget += amount
                    problem_objective.aol_project_budget += amount
                  elsif type == STAFF
                    output.aol_staff_budget += amount
                    problem_objective.aol_staff_budget += amount
                  else
                    p "Unidentified cost type: #{type}"
                  end
                elsif scenario == OL
                  if type == ADMIN
                    output.ol_admin_budget += amount
                    problem_objective.ol_admin_budget += amount
                  elsif type == PARTNER
                    output.ol_partner_budget += amount
                    problem_objective.ol_partner_budget += amount
                  elsif type == PROJECT
                    output.ol_project_budget += amount
                    problem_objective.ol_project_budget += amount
                  elsif type == STAFF
                    output.ol_staff_budget += amount
                    problem_objective.ol_staff_budget += amount
                  else
                    p "Unidentified cost type: #{type}"
                  end
                end

              end

              output.save
              problem_objective.save
            end

            xml_budget_lines = xml_problem_objective.search('./budgetLines/BudgetLine')

            xml_budget_lines.each do |xml_budget_line|
              scenario = xml_budget_line.search('./scenario').text
              amount = xml_budget_line.search('./amount').text.to_i
              type = xml_budget_line.search('./type').text

              if scenario == AOL
                if type == ADMIN
                  output.aol_admin_budget += amount
                  problem_objective.aol_admin_budget += amount
                elsif type == PARTNER
                  output.aol_partner_budget += amount
                  problem_objective.aol_partner_budget += amount
                elsif type == PROJECT
                  output.aol_project_budget += amount
                  problem_objective.aol_project_budget += amount
                elsif type == STAFF
                  output.aol_staff_budget += amount
                  problem_objective.aol_staff_budget += amount
                else
                  p "Unidentified cost type: #{type}"
                end
              elsif scenario == OL
                if type == ADMIN
                  output.ol_admin_budget += amount
                  problem_objective.ol_admin_budget += amount
                elsif type == PARTNER
                  output.ol_partner_budget += amount
                  problem_objective.ol_partner_budget += amount
                elsif type == PROJECT
                  output.ol_project_budget += amount
                  problem_objective.ol_project_budget += amount
                elsif type == STAFF
                  output.ol_staff_budget += amount
                  problem_objective.ol_staff_budget += amount
                else
                  p "Unidentified cost type: #{type}"
                end
              end

            end
            problem_objective.save

            # Impact indicators tied to objective
            xml_impact_indicators = xml_problem_objective.search('./indicators/Indicator')
            xml_impact_indicators.each do |xml_impact_indicator|
              (indicator = Indicator.find_or_initialize_by_id(:id => xml_impact_indicator.attribute('RFID').value).tap do |i|
                i.name = xml_impact_indicator.search('name').text
                i.is_performance = to_boolean(xml_impact_indicator.search('isPerformance').text)
                i.is_gsp = to_boolean(xml_impact_indicator.search('isGSP').text)
                i.id = xml_impact_indicator.attribute('RFID').value
              end).save

              problem_objective.indicators << indicator unless problem_objective.indicators.include? indicator
              operation.indicators << indicator unless operation.indicators.include? indicator
              plan.indicators << indicator unless plan.indicators.include? indicator
              # Create datum
              IndicatorDatum.find_or_initialize_by_id(:id => xml_impact_indicator.attribute('ID').value).tap do |d|
                d.id = xml_impact_indicator.attribute('ID').value
                d.goal = goal
                d.rights_group = rights_group
                d.plan = plan
                d.ppg = ppg
                d.problem_objective = problem_objective
                d.indicator = indicator
                d.operation = operation
                d.yer = xml_impact_indicator.search('./yearEndValue').text.to_i
                d.myr = xml_impact_indicator.search('./midYearValue').text.to_i
                d.standard = xml_impact_indicator.search('./standard').text.to_i
                d.baseline = xml_impact_indicator.search('./baseline').text.to_i
                d.comp_target = xml_impact_indicator.search('./compTarget').text.to_i
                d.threshold_red = xml_impact_indicator.search('./thresholdRed').text.to_i
                d.threshold_green = xml_impact_indicator.search('./thresholdGreen').text.to_i
                d.is_performance = false
                d.year = plan.year
              end.save

            end
          end
        end
      end
    end

  end

  def to_boolean(str)
    str == 'true'
  end
end
