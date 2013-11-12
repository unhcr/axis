module FocusParse
  PLAN = 'Plan'
  PROBLEM_OBJECTIVE = 'ProblemObjective'
  RIGHTS_GROUP = 'RightsGroup'
  GOAL = 'Goal'
  PPG = 'PPG'
  OUTPUT = 'Output'
  INDICATOR = 'Indicator'

  def parse(path)
    doc = Nokogiri::XML(File.read(path))

    xml_plan = doc.search(PLAN)

    plan = Plan.find_or_create(:id => xml_plan.attribute('ID').value) do |p|
      p.operation = xml_plan.search('./operation').text
      p.year = xml_plan.search('./year').text.to_i
      p.name = xml_plan.search('./name').text
    end

    xml_ppgs = xml_plan.search(PPG)

    xml_ppgs.each do |xml_ppg|

      ppg = Ppg.find_or_create(:id => xml_ppg.attribute('ID').value) do |p|
        p.name = xml_ppg.search('./name').text
      end

      xml_goals = xml_ppg.search(GOAL)

      xml_goals.each do |xml_goal|
        xml_rights_groups = xml_goal.search(RIGHTS_GROUP)

        goal = Goal.find_or_create(:id => xml_goal.attribute('ID').value) do |g|
          g.name = xml_goal.search('./name').text
        end

        xml_rights_groups.each do |xml_rights_group|
          xml_problem_objectives = xml_rights_group.search(PROBLEM_OBJECTIVE)

          rights_group = RightsGroup.find_or_create(:id => xml_rights_group.attribute('ID').value) do |rg|
            rg.name = xml_rights_group.search('./name').text
          end

          xml_problem_objectives.each do |xml_problem_objective|
            xml_outputs = xml_problem_objective.search(OUTPUT)

            problem_objective = ProblemObjective.find_or_create(:id => xml_problem_objective.attribute('ID').value)

            xml_outputs.each do |xml_output|
              # Must be performance indicators if part of output
              xml_performance_indicators = xml_output.search(INDICATOR)

              output = Output.find_or_create(:id => xml_output.attribute('ID').value)

              xml_performance_indicators.each do |xml_performance_indicator|
                indicator = Indicator.find_or_create(:id => xml_performance_indicator.attribute('ID').value) do |i|
                  i.name = xml_performance_indicator.search('name').text
                  i.isPerformance = to_boolean(xml_performance_indicator.search('isPerformance').text)
                  i.isGSP = to_boolean(xml_performance_indicator.search('isGSP').text)
                end

                # Create datum
                d = IndicatorDatum.create({
                  :isPerformance => to_boolean(xml_performance_indicator.search('isPerformance').text),
                  :isGSP => to_boolean(xml_performance_indicator.search('isGSP').text),
                  :name => xml_performance_indicator.search('name').text,
                  :yer => xml_performance_indicator.search('yearEndValue').text.to_i,
                  :standard => xml_performance_indicator.search('standard').text.to_i,
                  :baseline => xml_performance_indicator.search('baseline').text.to_i,
                  :comp_target => xml_performance_indicator.search('compTarget').text.to_i
                })
                d.goal = goal
                d.rights_group = rights_group
                d.plan = plan
                d.ppg = ppg
                d.problem_objective = problem_objective
                d.output = output
                d.indicator = indicator
                d.save

              end
            end

            # Impact indicators tied to objective
            xml_impact_indicators = xml_problem_objective.search('./indicators/Indicator')
            xml_impact_indicators.each do |xml_impact_indicator|
              indicator = Indicator.find_or_create(:id => xml_impact_indicator.attribute('ID').value) do |i|
                i.name = xml_performance_indicator.search('name').text
                i.isPerformance = to_boolean(xml_performance_indicator.search('isPerformance').text)
                i.isGSP = to_boolean(xml_performance_indicator.search('isGSP').text)
              end
              # Create datum
              d = IndicatorDatum.create({
                :isPerformance => to_boolean(xml_impact_indicator.search('isPerformance').text),
                :isGSP => to_boolean(xml_impact_indicator.search('isGSP').text),
                :name => xml_impact_indicator.search('name').text,
                :yer => xml_impact_indicator.search('yearEndValue').text.to_i,
                :standard => xml_impact_indicator.search('standard').text.to_i,
                :baseline => xml_impact_indicator.search('baseline').text.to_i,
                :comp_target => xml_impact_indicator.search('compTarget').text.to_i
              })
              d.goal = goal
              d.rights_group = rights_group
              d.ppg = ppg
              d.plan = plan
              d.problem_objective = problem_objective
              d.indicator = indicator
              d.save

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
