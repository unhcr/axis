module Parsers
  class IndicatorImpactParser < Parser
    MODEL = Indicator

    def self.csvfields
      @csvfields ||= {
        :id => 'ID',
        :name => 'NAME',
        :is_performance => lambda { |row| return false }
      }
    end

    def self.selector
      [:id]
    end

  end

end


