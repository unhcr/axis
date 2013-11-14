module FocusParse
  PLAN = 'Plan'
  PROBLEM_OBJECTIVE = 'ProblemObjective'
  RIGHTS_GROUP = 'RightsGroup'
  GOAL = 'Goal'
  PPG = 'PPG'
  OUTPUT = 'Output'
  INDICATOR = 'Indicator'

  def parse(file)
    #TODO Update new data pts if they created new data
    doc = Nokogiri::XML(file)

    xml_plan = doc.search(PLAN)

    plan = Plan.find_or_create_by_id(:id => xml_plan.attribute('ID').value) do |p|
      p.operation = xml_plan.search('./operation').text
      p.year = xml_plan.search('./year').text.to_i
      p.name = xml_plan.search('./name').text
      p.id = xml_plan.attribute('ID').value
    end

    xml_ppgs = xml_plan.search(PPG)

    xml_ppgs.each do |xml_ppg|

      ppg = Ppg.find_or_create_by_id(:id => xml_ppg.search('./name').text) do |p|
        p.name = xml_ppg.search('./name').text
        p.id = xml_ppg.search('./name').text
      end

      plan.ppgs << ppg

      xml_goals = xml_ppg.search(GOAL)

      xml_goals.each do |xml_goal|
        xml_rights_groups = xml_goal.search(RIGHTS_GROUP)

        goal = Goal.find_or_create_by_id(:id => xml_goal.attribute('RFID').value) do |g|
          g.name = xml_goal.search('./name').text
          g.id = xml_goal.attribute('RFID').value
        end

        ppg.goals << goal

        xml_rights_groups.each do |xml_rights_group|
          xml_problem_objectives = xml_rights_group.search(PROBLEM_OBJECTIVE)

          rights_group = RightsGroup.find_or_create_by_id(:id => xml_rights_group.attribute('RFID').value) do |rg|
            rg.name = xml_rights_group.search('./name').text
            rg.id = xml_rights_group.attribute('RFID').value
          end

          goal.rights_groups << rights_group

          xml_problem_objectives.each do |xml_problem_objective|
            xml_outputs = xml_problem_objective.search(OUTPUT)

            problem_objective = ProblemObjective.find_or_create_by_id(:id => xml_problem_objective.attribute('RFID').value) do |po|
              po.objective_name = xml_problem_objective.search('./objectiveName').text
              po.problem_name = xml_problem_objective.search('./problemName').text
              po.is_excluded = to_boolean(xml_problem_objective.search('./isExcluded').text)
              po.id = xml_problem_objective.attribute('RFID').value
            end

            rights_group.problem_objectives << problem_objective

            xml_outputs.each do |xml_output|
              # Must be performance indicators if part of output
              xml_performance_indicators = xml_output.search(INDICATOR)

              output = Output.find_or_create_by_id(:id => xml_output.attribute('RFID').value) do |o|
                o.name = xml_output.search('./name').text
                o.priority = xml_output.search('./priority').text
                o.id = xml_output.attribute('RFID').value
              end

              problem_objective.outputs << output

              xml_performance_indicators.each do |xml_performance_indicator|
                indicator = Indicator.find_or_create_by_id(:id => xml_performance_indicator.attribute('RFID').value) do |i|
                  i.name = xml_performance_indicator.search('name').text
                  i.is_performance = to_boolean(xml_performance_indicator.search('isPerformance').text)
                  i.is_gsp = to_boolean(xml_performance_indicator.search('isGSP').text)
                  i.id = xml_performance_indicator.attribute('RFID').value
                end

                output.indicators << indicator

                # Create datum
                datum = IndicatorDatum.find_or_create_by_id(:id => xml_performance_indicator.attribute('ID').value) do |d|
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

              problem_objective.indicators << indicator

              # Create datum
              datum = IndicatorDatum.find_or_create_by_id(:id => xml_impact_indicator.attribute('ID').value) do |d|
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
