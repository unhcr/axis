module Parsers

  class ElementsParser < Parser

    PERF_INDICATORS = 'perf'
    IMPACT_INDICATORS = 'impact'
    # Parses all elements
    def self.csvfields
      @csvfields ||= {
        :operations => {
          :id => 'OPERATIONID',
          :name => 'OPERATION'
        },
        :plans => {
          :id => 'PLANID',
          :name => 'PLAN_NAME',
          :year => 'PLANNINGYEAR',
          :operation_name => 'OPERATION',
          :operation_id => 'OPERATIONID'
        },
        :ppgs => {
          :id => 'PPGID',
          :msrp_code => 'PPG_CODE',
          :name => 'PPG',
          :operation_name => 'OPERATION'
        },
        :goals => {
          :id => 'RFGOALID',
          :name => 'GOAL_NAME'
        },
        :rights_groups => {
          :id => 'RFRIGHTSGROUPID',
          :name => 'RIGHTS_GROUP_NAME'
        },
        :problem_objectives => {
          :id => 'RFPROBLEMOBJECTIVEID',
          :problem_name => 'PROBLEMNAME',
          :objective_name => 'OBJECTIVENAME'
        },
        :outputs => {
          :id => 'RFOUTPUTID',
          :name => 'OUTPUT_NAME'
        },
        :perf_indicators => {
          :id => 'PERFINDICATOR_RFID',
          :name => 'PERFINDICATOR_NAME',
          :is_performance => lambda { |row| is_performance_indicator?(Indicator, row) == PERF_INDICATORS }
        },
        :impact_indicators => {
          :id => 'IMPACTINDICATOR_RFID',
          :name => 'IMPACTINDICATOR_NAME',
          :is_performance => lambda { |row| is_performance_indicator?(Indicator, row) == PERF_INDICATORS}
        },
      }

    end

    # @param: indicator_type - 'impact' or 'perf' indicators whether or not it's a perf or impact indicator. If it
    # isn't a indicator, then parameter should be nil
    def resource_to_csvfield_attrs(resource, indicator_type = nil)
      if resource != Indicator
        return ElementsParser.csvfields[resource.table_name.to_sym]
      else
        return ElementsParser.csvfields["#{indicator_type}_#{resource.table_name}".to_sym]
      end
    end

    def attrs(resource)
      resources.accessible_attributes.select { |attr| not attr.empty? }
    end

    def is_performance_indicator?(resource, row)
      is_performance = nil

      # Hack to handle indicators
      if resource == Indicator
        if skip? row['IMPACTINDICATOR_RFID']
          is_performance = PERF_INDICATORS
        else
          is_performance = IMPACT_INDICATORS
        end
      end
      is_performance

    end

    def skip?(resource_id)
      resource_id == NULL or resource_id.nil?
    end

    def parse(csv_filename)

      resources = [Operation, Plan, Ppg, Goal, RightsGroup, ProblemObjective, Output, Indicator]
      @elements = {
        Operation => [],
        Plan => [],
        Ppg => [],
        Goal => [],
        RightsGroup => [],
        ProblemObjective => [],
        Output => [],
        Indicator => []
      }
      @relations = {
        GoalsOperations => [],
        GoalsPlans => [],
        GoalsPpgs => [],
        GoalsProblemObjectives => [],
        GoalsRightsGroups => [],
        GoalsIndicators => [],
        GoalsOutputs => [],
        IndicatorsOperations => [],
        IndicatorsOutputs => [],
        IndicatorsPlans => [],
        IndicatorsProblemObjectives => [],
        IndicatorsPpgs => [],
        OperationsOutputs => [],
        OperationsPpgs => [],
        OperationsProblemObjectives => [],
        OperationsRightsGroups => [],
        OutputsPlans => [],
        OutputsProblemObjectives => [],
        OutputsPpgs => [],
        PlansPpgs => [],
        PlansProblemObjectives => [],
        PlansRightsGroups => [],
        ProblemObjectivesRightsGroups => [],
        PpgsProblemObjectives => []
      }

      p 'Reading CSV'
      csv_foreach(csv_filename) do |row|
        next if row.empty?
        # Just parse all the parameters in the row
        resources.each do |r|
          attrs = resource_to_csvfield_attrs r, is_performance_indicator?(r, row)
          resource_id = row[attrs[:id]]

          next if skip?(resource_id)

          @elements[r] << csv_parse_element(attrs, row)
        end

        # Establish many-to-many relations
        resources.each do |resource|


          attrs = resource_to_csvfield_attrs resource, is_performance_indicator?(resource, row)
          resource_id = row[attrs[:id]]

          next if skip?(resource_id)

          resources.each do |relation|
            table_name = [relation.table_name, resource.table_name].sort.join('_')
            reflection = resource.reflect_on_association(table_name.to_sym)
            next unless reflection
            association = reflection.name.to_s.camelize.constantize

            if @relations.has_key? association
              classes = [resource, relation].sort { |c1, c2| c1.to_s <=> c2.to_s }
              values = []
              classes.each do |clazz|
                attrs = resource_to_csvfield_attrs clazz, is_performance_indicator?(clazz, row)
                values << row[attrs[:id]]

              end
              @relations[association] << values
            end

          end

        end

      end

      p 'Importing Elements'

      # import elements
      @elements.each do |resource, values|
        attrs = nil
        if resource == Indicator
          attrs = ElementsParser.csvfields["perf_#{resource.table_name}".to_sym]
        else
          attrs = ElementsParser.csvfields[resource.table_name.to_sym]
        end
        columns = attrs.keys
        columns << :found_at

        to_update = columns.dup
        to_update.delete :id

        resource.import columns, values, :on_duplicate_key_update => to_update
      end

      p 'Importing Relations'
      # import relations
      @relations.each do |relation, values|
        columns = relation.attribute_names.sort
        columns.delete 'id'
        relation.import columns, values, :on_duplicate_key_update => columns
      end

    end

  end
end
