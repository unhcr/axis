module Parsers
  class IndicatorDataPerfParser < IndicatorDataParser

    def self.csvfields
      fields = super
      @csvfields = {
        :output_id => 'RFOUTPUTID',
        :indicator_id => 'PERFINDICATOR_RFID',
        :id => 'PERFINDICATOR_ID',
        :yer => 'PERF_YEAR_END_VALUE',
        :myr => 'PERF_MID_YEAR_VALUE',
        :imp_target => 'PERF_IMP_TARGET',
        :comp_target => 'PERF_COMP_TARGET',
        :is_performance => lambda { |row| true },
      }.merge(fields)

    end

    def self.selector
      [:id]
    end

  end
end
