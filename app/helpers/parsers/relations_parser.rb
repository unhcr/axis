module Parsers

  class RelationsParser < Parser

    PERF_INDICATORS = 'perf'
    IMPACT_INDICATORS = 'impact'
    # Parses all elements
    def self.csvfields
      @csvfields ||= {
        :operation_id => 'OPERATIONID',
        :plan_id => 'PLANID',
        :ppg_id => 'PPGID',
        :goal_id => 'RFGOALID',
        :rights_group_id => 'RFRIGHTSGROUPID',
        :problem_objective_id => 'RFPROBLEMOBJECTIVEID',
        :output_id => 'RFOUTPUTID',
        :perf_indicator_id => 'PERFINDICATOR_RFID',
        :impact_indicator_id => 'IMPACTINDICATOR_RFID',
      }

    end

    # @param: indicator_type - 'impact' or 'perf' indicators whether or not it's a perf or impact indicator. If it
    # isn't a indicator, then parameter should be nil
    def resource_to_csvfield_attrs(resource, indicator_type = nil)
      if resource != Indicator
        return RelationsParser.csvfields[resource.table_name.to_sym]
      else
        return RelationsParser.csvfields["#{indicator_type}_#{resource.table_name}".to_sym]
      end
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

      @relations = [
        GoalsOperations,
        GoalsProblemObjectives,
        GoalsIndicators,
        GoalsOutputs,
        IndicatorsOperations,
        IndicatorsOutputs,
        IndicatorsProblemObjectives,
        IndicatorsPpgs,
        OperationsOutputs,
        OperationsPpgs,
        OperationsProblemObjectives,
        OutputsProblemObjectives,
        OutputsPpgs,
        PpgsProblemObjectives
      ]
      csvfields = RelationsParser.csvfields

      p 'Reading CSV'
      @relations.each do |association|
        p "Parsing #{association.to_s}"
        Upsert.batch(ActiveRecord::Base.connection, association.table_name.to_sym) do |upsert|
          csv_foreach(csv_filename) do |row|
            next if row.empty?

            attrs = association.attribute_names.map &:to_sym

            relation = {}

            attrs.each do |attr|
              accessor = attr
              if attr == :indicator_id
                indicator_type = is_performance_indicator? Indicator, row
                if indicator_type == PERF_INDICATORS
                  accessor = :perf_indicator_id
                else
                  accessor = :impact_indicator_id
                end
              end
              relation[attr] = row[csvfields[accessor]]
            end

            upsert.row relation, {} if relation.values.all? { |v| v.present? }

          end
        end
      end
    end

  end
end
