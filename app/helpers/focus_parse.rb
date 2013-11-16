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
      id = xml_operation_header.attribute('ID').value
      name = xml_operation_header.search('./name').text
      years = []


      plan_types.each do |type|
        years += xml_operation_header.search(
          "./plans/PlanHeader[type = \"#{type}\"]/planningPeriod").map(&:text)
      end

      Operation.find_or_create_by_id(:id => id) do |o|
        o.id = id
        o.name = name
        o.years = years.uniq
      end

    end

    return ret

  end

  def parse_plan(file)
    #TODO Update new data pts if they created new data
    doc = Nokogiri::XML(file)

    xml_plan = doc.search(PLAN)

    plan = Plan.find_or_create_by_id(:id => xml_plan.attribute('ID').value) do |p|
      p.operation_name = xml_plan.search('./operation').text
      p.year = xml_plan.search('./year').text.to_i
      p.name = xml_plan.search('./name').text
      p.id = xml_plan.attribute('ID').value
    end

    # Use ID once it's in the XML
    operation = Operation.where(:name => plan.operation_name).first
    operation.plans << plan unless operation.plans.include? plan

    xml_ppgs = xml_plan.search(PPG)

    xml_ppgs.each do |xml_ppg|

      ppg = Ppg.find_or_create_by_id(xml_ppg.search('./name').text) do |p|
        p.name = xml_ppg.search('./name').text
        p.id = xml_ppg.search('./name').text
      end

      plan.ppgs << ppg unless plan.ppgs.include? ppg

      xml_goals = xml_ppg.search(GOAL)

      xml_goals.each do |xml_goal|
        xml_rights_groups = xml_goal.search(RIGHTS_GROUP)

        goal = Goal.find_or_create_by_id(:id => xml_goal.attribute('RFID').value) do |g|
          g.name = xml_goal.search('./name').text
          g.id = xml_goal.attribute('RFID').value
        end

        ppg.goals << goal unless ppg.goals.include? goal

        xml_rights_groups.each do |xml_rights_group|
          xml_problem_objectives = xml_rights_group.search(PROBLEM_OBJECTIVE)

          rights_group = RightsGroup.find_or_create_by_id(:id => xml_rights_group.attribute('RFID').value) do |rg|
            rg.name = xml_rights_group.search('./name').text
            rg.id = xml_rights_group.attribute('RFID').value
          end

          goal.rights_groups << rights_group unless goal.rights_groups.include? rights_group

          xml_problem_objectives.each do |xml_problem_objective|
            xml_outputs = xml_problem_objective.search(OUTPUT)

            problem_objective = ProblemObjective.find_or_create_by_id(:id => xml_problem_objective.attribute('RFID').value) do |po|
              po.objective_name = xml_problem_objective.search('./objectiveName').text
              po.problem_name = xml_problem_objective.search('./problemName').text
              po.is_excluded = to_boolean(xml_problem_objective.search('./isExcluded').text)
              po.id = xml_problem_objective.attribute('RFID').value
            end

            unless rights_group.problem_objectives.include? problem_objective
              rights_group.problem_objectives << problem_objective
            end

            xml_outputs.each do |xml_output|
              # Must be performance indicators if part of output
              xml_performance_indicators = xml_output.search(INDICATOR)
              xml_budget_lines = xml_output.search(BUDGET_LINE)

              output = Output.find_or_create_by_id(:id => xml_output.attribute('RFID').value) do |o|
                o.name = xml_output.search('./name').text
                o.priority = xml_output.search('./priority').text
                o.id = xml_output.attribute('RFID').value
              end

              problem_objective.outputs << output unless problem_objective.outputs.include? output

              xml_performance_indicators.each do |xml_performance_indicator|
                indicator = Indicator.find_or_create_by_id(:id => xml_performance_indicator.attribute('RFID').value) do |i|
                  i.name = xml_performance_indicator.search('name').text
                  i.is_performance = to_boolean(xml_performance_indicator.search('isPerformance').text)
                  i.is_gsp = to_boolean(xml_performance_indicator.search('isGSP').text)
                  i.id = xml_performance_indicator.attribute('RFID').value
                end

                output.indicators << indicator unless output.indicators.include? indicator

                # Create datum
                IndicatorDatum.find_or_create_by_id(:id => xml_performance_indicator.attribute('ID').value) do |d|
                  d.id = xml_performance_indicator.attribute('ID').value
                  d.goal = goal
                  d.rights_group = rights_group
                  d.plan = plan
                  d.ppg = ppg
                  d.problem_objective = problem_objective
                  d.output = output
                  d.indicator = indicator
                  d.yer = xml_performance_indicator.search('./yearEndValue').text.to_i
                  d.standard = xml_performance_indicator.search('./standard').text.to_i
                  d.baseline = xml_performance_indicator.search('./baseline').text.to_i
                  d.comp_target = xml_performance_indicator.search('./compTarget').text.to_i
                end

              end

              xml_budget_lines.each do |xml_budget_line|

                BudgetLine.find_or_create_by_id(:id => xml_budget_line.attribute('ID').value) do |b|
                  b.id = xml_budget_line.attribute('ID').value
                  b.goal = goal
                  b.rights_group = rights_group
                  b.plan = plan
                  b.ppg = ppg
                  b.problem_objective = problem_objective
                  b.output = output

                  b.account_code = xml_budget_line.search('./accountCode').text
                  b.account_name = xml_budget_line.search('./accountName').text
                  b.amount = xml_budget_line.search('./amount').text.to_i
                  b.comment = xml_budget_line.search('./comment').text
                  b.cost_center = xml_budget_line.search('./costCenter').text
                  b.currency = xml_budget_line.search('./currency').text
                  b.implementer_code = xml_budget_line.search('./implementerCode').text
                  b.implementer_name = xml_budget_line.search('./implementerName').text
                  b.local_cost = xml_budget_line.search('./localCost').text
                  b.quantity = xml_budget_line.search('./quantity').text.to_i
                  b.scenerio = xml_budget_line.search('./scenerio').text
                  b.cost_type = xml_budget_line.search('./type').text
                  b.unit = xml_budget_line.search('./unit').text
                  b.unit_cost = xml_budget_line.search('./unitCost').text.to_i
                end

              end
            end

            xml_budget_lines = xml_problem_objective.search('./budgetLines/BudgetLine')

            xml_budget_lines.each do |xml_budget_line|

              BudgetLine.find_or_create_by_id(:id => xml_budget_line.attribute('ID').value) do |b|
                b.id = xml_budget_line.attribute('ID').value
                b.goal = goal
                b.rights_group = rights_group
                b.plan = plan
                b.ppg = ppg
                b.problem_objective = problem_objective

                b.account_code = xml_budget_line.search('./accountCode').text
                b.account_name = xml_budget_line.search('./accountName').text
                b.amount = xml_budget_line.search('./amount').text.to_i
                b.comment = xml_budget_line.search('./comment').text
                b.cost_center = xml_budget_line.search('./costCenter').text
                b.currency = xml_budget_line.search('./currency').text
                b.implementer_code = xml_budget_line.search('./implementerCode').text
                b.implementer_name = xml_budget_line.search('./implementerName').text
                b.local_cost = xml_budget_line.search('./localCost').text
                b.quantity = xml_budget_line.search('./quantity').text.to_i
                b.scenerio = xml_budget_line.search('./scenerio').text
                b.cost_type = xml_budget_line.search('./type').text
                b.unit = xml_budget_line.search('./unit').text
                b.unit_cost = xml_budget_line.search('./unitCost').text.to_i
              end

            end
            # Impact indicators tied to objective
            xml_impact_indicators = xml_problem_objective.search('./indicators/Indicator')
            xml_impact_indicators.each do |xml_impact_indicator|
              indicator = Indicator.find_or_create_by_id(:id => xml_impact_indicator.attribute('RFID').value) do |i|
                i.name = xml_impact_indicator.search('name').text
                i.is_performance = to_boolean(xml_impact_indicator.search('isPerformance').text)
                i.is_gsp = to_boolean(xml_impact_indicator.search('isGSP').text)
                i.id = xml_impact_indicator.attribute('RFID').value
              end

              problem_objective.indicators << indicator unless problem_objective.indicators.include? indicator

              # Create datum
              IndicatorDatum.find_or_create_by_id(:id => xml_impact_indicator.attribute('ID').value) do |d|
                d.id = xml_impact_indicator.attribute('ID').value
                d.goal = goal
                d.rights_group = rights_group
                d.plan = plan
                d.ppg = ppg
                d.problem_objective = problem_objective
                d.indicator = indicator
                d.yer = xml_impact_indicator.search('./yearEndValue').text.to_i
                d.standard = xml_impact_indicator.search('./standard').text.to_i
                d.baseline = xml_impact_indicator.search('./baseline').text.to_i
                d.comp_target = xml_impact_indicator.search('./compTarget').text.to_i
              end

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
