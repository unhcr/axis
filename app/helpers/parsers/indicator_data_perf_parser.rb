module Parsers
  class IndicatorDataPerfParser < IndicatorDataParser

    def self.csvfields
      fields = super
      @csvfields = {
        :output_id => 'RFOUTPUTID',
        :indicator_id => 'PERFINDICATOR_RFID',
        :id => 'PERFINDICATOR_ID',
        :yer => lambda { |row| indicator_value_parse(row, 'PERF_YEAR_END_VALUE') },
        :myr => lambda { |row| indicator_value_parse(row, 'PERF_MID_YEAR_VALUE') },
        :imp_target => lambda { |row| indicator_value_parse(row, 'PERF_IMP_TARGET') },
        :comp_target => lambda { |row| indicator_value_parse(row, 'PERF_COMP_TARGET') },
        :is_performance => lambda { |row| true },
      }.merge(fields)

    end

  end
end
