module Parsers
  class IndicatorImpactParser < IndicatorParser
    MODEL = Indicator

    def self.csvfields
      @csvfields ||= {
        :id => 'ID',
        :name => 'NAME',
        :is_performance => lambda { |row| return false }
      }
    end

    def self.relationfields
      @relationfields ||= {
        :problem_objective_id => 'RFPROBOBJ_ID'
      }
    end

    def self.selector
      [:id]
    end

    def self.relations
      [IndicatorsProblemObjectives]
    end
  end
end


