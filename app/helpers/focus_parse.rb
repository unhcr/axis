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

  PRIORITIES = {
    :aol => 'AOL',
    :wol => 'WOL',
    :partial => 'PARTIAL'
  }

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
    plan.found

    unless plan.country
      match_model_to_country(plan, plan.operation_name)
    end

    operation = Operation.find(xml_plan.search('./operationID').text)
    operation.plans << plan unless operation.plans.include? plan

    xml_ppgs = xml_plan.search(PPG)

    # Parse PPGs
    xml_ppgs.each do |xml_ppg|

      (ppg = Ppg.find_or_initialize_by_id(xml_ppg.attribute('POPGRPID').value).tap do |p|
        p.name = xml_ppg.search('./name').text
        p.id = xml_ppg.attribute('POPGRPID').value
        p.population_type = xml_ppg.search('./typeName').text
        p.population_type_id = xml_ppg.search('./typeID').text
        p.operation_name = operation.name
      end).save
      ppg.found

      plan.ppgs << ppg unless plan.ppgs.include? ppg
      operation.ppgs << ppg unless operation.ppgs.include? ppg

      xml_goals = xml_ppg.search(GOAL)

      # Parse Goals
      xml_goals.each do |xml_goal|
        xml_rights_groups = xml_goal.search(RIGHTS_GROUP)

        (goal = Goal.find_or_initialize_by_id(:id => xml_goal.attribute('RFID').value).tap do |g|
          g.name = xml_goal.search('./name').text
          g.id = xml_goal.attribute('RFID').value
        end).save
        goal.found

        pillar = xml_goal.search('./pillar').text

        ppg.goals << goal unless ppg.goals.include? goal
        operation.goals << goal unless operation.goals.include? goal
        plan.goals << goal unless plan.goals.include? goal

        # Parse Rights Groups
        xml_rights_groups.each do |xml_rights_group|
          xml_problem_objectives = xml_rights_group.search(PROBLEM_OBJECTIVE)

          (rights_group = RightsGroup.find_or_initialize_by_id(:id => xml_rights_group.attribute('RFID').value).tap do |rg|
            rg.name = xml_rights_group.search('./name').text
            rg.id = xml_rights_group.attribute('RFID').value
          end).save
          rights_group.found

          goal.rights_groups << rights_group unless goal.rights_groups.include? rights_group
          operation.rights_groups << rights_group unless operation.rights_groups.include? rights_group
          plan.rights_groups << rights_group unless plan.rights_groups.include? rights_group

          # Parse Problem Objectives
          xml_problem_objectives.each do |xml_problem_objective|
            xml_outputs = xml_problem_objective.search(OUTPUT)

            (problem_objective = ProblemObjective.find_or_initialize_by_id(:id => xml_problem_objective.attribute('RFID').value).tap do |po|
              po.objective_name = xml_problem_objective.search('./objectiveName').text
              po.problem_name = xml_problem_objective.search('./problemName').text
              po.is_excluded = to_boolean(xml_problem_objective.search('./isExcluded').text)
              po.id = xml_problem_objective.attribute('RFID').value
            end).save
            problem_objective.found

            missing_budget = true

            unless rights_group.problem_objectives.include? problem_objective
              rights_group.problem_objectives << problem_objective
            end
            unless operation.problem_objectives.include? problem_objective
              operation.problem_objectives << problem_objective
            end
            unless plan.problem_objectives.include? problem_objective
              plan.problem_objectives << problem_objective
            end
            unless goal.problem_objectives.include? problem_objective
              goal.problem_objectives << problem_objective
            end

            # Parse Outputs
            xml_outputs.each do |xml_output|
              # Must be performance indicators if part of output
              xml_performance_indicators = xml_output.search(INDICATOR)
              xml_budget_lines = xml_output.search(BUDGET_LINE)

              (output = Output.find_or_initialize_by_id(:id => xml_output.attribute('RFID').value).tap do |o|
                o.name = xml_output.search('./name').text
                o.id = xml_output.attribute('RFID').value
              end).save
              output.found


              priority = xml_output.search('./priority').text
              missing_budget = false if priority != PRIORITIES[:aol]

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
                indicator.found

                output.indicators << indicator unless output.indicators.include? indicator
                operation.indicators << indicator unless operation.indicators.include? indicator
                plan.indicators << indicator unless plan.indicators.include? indicator

                # Create datum
                (datum = IndicatorDatum.find_or_initialize_by_id(:id => xml_performance_indicator.attribute('ID').value).tap do |d|
                  d.id = xml_performance_indicator.attribute('ID').value
                  d.goal = goal
                  d.rights_group = rights_group
                  d.plan = plan
                  priority = xml_output.search('./priority').text
                  if priority == PRIORITIES[:aol]
                    d.missing_budget = true
                  else
                    d.missing_budget = false
                  end
                  d.ppg = ppg
                  d.problem_objective = problem_objective
                  d.output = output
                  d.operation = operation
                  d.indicator = indicator
                  yer = xml_performance_indicator.search('./yearEndValue').text
                  d.yer = yer.empty? ? nil : yer.to_i

                  myr = xml_performance_indicator.search('./midYearValue').text
                  d.myr = myr.empty? ? nil : myr.to_i

                  standard = xml_performance_indicator.search('./standard').text
                  d.standard = standard.empty? ? nil : standard.to_i

                  baseline = xml_performance_indicator.search('./baseline').text
                  d.baseline = baseline.empty? ? nil : baseline.to_i

                  comp_target = xml_performance_indicator.search('./compTarget').text
                  d.comp_target = comp_target.empty? ? nil : comp_target.to_i

                  imp_target = xml_performance_indicator.search('./impTarget').text
                  d.imp_target = imp_target.empty? ? nil : imp_target.to_i

                  d.is_performance = true
                  d.year = plan.year
                end).save
                datum.found
              end

              budget_hash_list = []

              [AOL, OL].each do |scenario|
                [ADMIN, PARTNER, PROJECT, STAFF].each do |budget_type|
                  budget_hash_list << {
                    :budget_type => budget_type,
                    :scenario => scenario,
                    :amount => 0
                  }
                end
              end

              xml_budget_lines.each do |xml_budget_line|
                scenario = xml_budget_line.search('./scenario').text
                amount = xml_budget_line.search('./amount').text.to_i
                type = xml_budget_line.search('./type').text

                hash = budget_hash(budget_hash_list, scenario, type)
                p "Unidentified cost type: #{type} | #{scenario}" unless hash
                hash[:amount] += amount
              end

              budget_hash_list.each do |hash|
                next if hash[:amount] == 0
                attrs = {
                  :plan_id => plan.id,
                  :ppg_id => ppg.id,
                  :goal_id => goal.id,
                  :output_id => output.id,
                  :problem_objective_id => problem_objective.id,
                  :scenario => hash[:scenario],
                  :budget_type => hash[:budget_type],
                }

                b = Budget.where(attrs).first
                b = Budget.new() unless b

                b.plan = plan
                b.ppg = ppg
                b.goal = goal
                b.output = output
                b.problem_objective = problem_objective
                b.operation = operation
                b.pillar = pillar

                b.amount = hash[:amount]
                b.scenario = hash[:scenario]
                b.budget_type = hash[:budget_type]
                b.year = plan.year
                b.save
                p "No pillar for budget: #{b.id}" unless b.pillar
                b.found
              end
              output.save
              problem_objective.save
            end

            xml_budget_lines = xml_problem_objective.search('./budgetLines/BudgetLine')
            p 'Budget without output!' if xml_budget_lines.length > 0

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
              indicator.found

              problem_objective.indicators << indicator unless problem_objective.indicators.include? indicator
              operation.indicators << indicator unless operation.indicators.include? indicator
              plan.indicators << indicator unless plan.indicators.include? indicator
              # Create datum
              (datum = IndicatorDatum.find_or_initialize_by_id(:id => xml_impact_indicator.attribute('ID').value).tap do |d|
                d.id = xml_impact_indicator.attribute('ID').value
                d.goal = goal
                d.rights_group = rights_group
                d.plan = plan
                d.ppg = ppg
                d.problem_objective = problem_objective
                d.indicator = indicator
                d.operation = operation
                d.missing_budget = missing_budget

                yer = xml_impact_indicator.search('./yearEndValue').text
                d.yer = yer.empty? ? nil : yer.to_i

                myr = xml_impact_indicator.search('./midYearValue').text
                d.myr = myr.empty? ? nil : myr.to_i

                standard = xml_impact_indicator.search('./standard').text
                d.standard = standard.empty? ? nil : standard.to_i

                baseline = xml_impact_indicator.search('./baseline').text
                d.baseline = baseline.empty? ? nil : baseline.to_i

                comp_target = xml_impact_indicator.search('./compTarget').text
                d.comp_target = comp_target.empty? ? nil : comp_target.to_i

                imp_target = xml_impact_indicator.search('./impTarget').text
                d.imp_target = imp_target.empty? ? nil : imp_target.to_i

                d.threshold_red = xml_impact_indicator.search('./thresholdRed').text.to_i
                d.threshold_green = xml_impact_indicator.search('./thresholdGreen').text.to_i
                d.is_performance = false
                d.year = plan.year
              end).save
              datum.found

            end
          end
        end
      end
    end

    xml_office = xml_plan.search('./office')[0]

    recursive_office_parse(xml_office, nil, operation, plan)

  end

  def recursive_office_parse(xml_office, parent_office, operation, plan)

    (office = Office.find_or_initialize_by_id(:id => xml_office.attribute('ID').value).tap do |o|

      # Fill in properties
      o.id = xml_office.attribute('ID').value
      o.name = xml_office.search('./name').text
      o.operation = operation
      o.plan = plan
      o.parent_office = parent_office

    end).save
    office.found

    xml_parent_position = xml_office.search('./headPosition')

    recursive_position_parse(xml_parent_position, nil, operation, plan, office) if xml_parent_position
    xml_sub_offices = xml_office.search('./subOffice')

    xml_sub_offices.each do |xml_sub_office|

      recursive_office_parse(xml_sub_office, office, operation, plan)
    end
  end

  def recursive_position_parse(xml_position, parent_position, operation, plan, office)

    (position = Position.find_or_initialize_by_id(:id => xml_position.attribute('ID').value).tap do |p|

      # Fill in properties
      p.id = xml_position.attribute('ID').value
      p.title = xml_position.search('./title').text
      p.grade = xml_position.search('./grade').text
      p.contract_type = xml_position.search('./contractType').text
      p.incumbent = xml_position.search('./incumbent').text
      p.position_reference = xml_position.search('./positionID').text
      p.office = office

      fast_track = xml_position.search('./fastTrack').text == 'Y'
      p.fast_track = fast_track

      p.operation = operation
      p.plan = plan

      p.parent_position = parent_position

    end).save
    position.found

    xml_sub_positions = xml_position.search('./subPosition')

    xml_sub_positions.each do |xml_sub_position|
      recursive_position_parse(xml_sub_position, position, operation, plan, office)
    end
  end

  def budget_hash(list, scenario, budget_type)
    hashes = list.select do |hash|
      hash[:budget_type] == budget_type && hash[:scenario] == scenario
    end
    return hashes.first
  end

  def to_boolean(str)
    str == 'true'
  end
end
