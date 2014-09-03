module Parsers
  class IndicatorPerfParser < Parser
    MODEL = Indicator

    def self.csvfields
      @csvfields ||= {
        :id => 'ID',
        :name => 'NAME',
        :is_performance => lambda { |row| return true }
      }
    end

    def self.selector
      [:id]
    end

  end

end


