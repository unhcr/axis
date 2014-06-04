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
          :operation_name => 'OPERATION'
        },
        :ppgs => {
          :id => 'PPGID',
          :name => 'PPG'
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

      csv_foreach(csv_filename) do |row|
        next if row.empty?
        # Just parse all the parameters in the row
        resources.each do |r|
          attrs = resource_to_csvfield_attrs r, is_performance_indicator?(r, row)
          resource_id = row[attrs[:id]]

          next if skip?(resource_id)

          parse_element r, row, attrs
        end

        # Establish many-to-many relations
        resources.each do |resource|


          attrs = resource_to_csvfield_attrs resource, is_performance_indicator?(resource, row)
          resource_id = row[attrs[:id]]

          next if skip?(resource_id)

          element = resource.find resource_id

          resources.each do |relation|
            table_name = relation.table_name

            if element.respond_to? table_name
              attrs = resource_to_csvfield_attrs relation, is_performance_indicator?(relation, row)
              id = row[attrs[:id]]
              next if skip?(id)

              relationElement = relation.find id
              unless element.send(table_name).include? relationElement
                element.send(table_name) << relationElement
              end
            end


          end
        end
      end

    end

    def parse_element(resource, row, attrs)
      id = row[attrs[:id]]
      (element = resource.find_or_initialize_by_id(:id => id).tap do |e|
        attrs.each do |rails_attr, csvfield_attr|
          # If it's a lambda, call it
          if csvfield_attr.respond_to? :call
            e[rails_attr] = instance_exec row, &csvfield_attr
          else
            e[rails_attr] = row[csvfield_attr]
          end
        end

      end).save
      element.found
      element
    end

  end
end
