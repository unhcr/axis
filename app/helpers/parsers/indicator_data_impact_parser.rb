module Parsers

  class IndicatorDataImpactParser < IndicatorDataParser

    def self.csvfields
      fields = super
      @csvfields = {
        :indicator_id => 'IMPACTINDICATOR_RFID',
        :id => 'IMPINDICATOR_ID',
        :yer => lambda { |row| indicator_value_parse(row, 'IMP_YEAR_END_VALUE') },
        :myr => lambda { |row| indicator_value_parse(row, 'IMP_MID_YEAR_VALUE') },
        :imp_target => lambda { |row| indicator_value_parse(row, 'IMP_IMP_TARGET') },
        :comp_target => lambda { |row| indicator_value_parse(row, 'IMP_COMP_TARGET') },
        :baseline => lambda { |row| indicator_value_parse(row, 'IMP_BASELINE') },
        :standard => lambda { |row| indicator_value_parse(row, 'IMP_STANDARD') },
        :threshold_red => lambda { |row| indicator_value_parse(row, 'IMP_RED') },
        :threshold_green => lambda { |row| indicator_value_parse(row, 'IMP_GREEN') },
        :is_performance => lambda { |row| false },
      }.merge(fields)
    end

  end
end
