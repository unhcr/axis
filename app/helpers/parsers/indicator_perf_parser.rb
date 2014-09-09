module Parsers
  class IndicatorPerfParser < IndicatorParser
    MODEL = Indicator

    def self.csvfields
      @csvfields ||= {
        :id => 'ID',
        :name => 'NAME',
        :is_performance => lambda { |row| return true }
      }
    end

    def self.relationfields
      @relationfields ||= {
        :output_id => 'RFOUTPUT_ID'
      }
    end

    def self.selector
      [:id]
    end

    def self.relations
      [IndicatorsOutputs]
    end

  end

end


