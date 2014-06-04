module Parsers

  class IndicatorDataImpactParser < IndicatorDataParser

    def self.csvfields
      fields = super
      @csvfields = {
        :indicator_id => 'IMPACTINDICATOR_RFID',
        :id => 'IMPINDICATOR_ID',
        :yer => 'IMP_YEAR_END_VALUE',
        :myr => 'IMP_MID_YEAR_VALUE',
        :imp_target => 'IMP_IMP_TARGET',
        :comp_target => 'IMP_COMP_TARGET',
        :baseline => 'IMP_BASELINE',
        :standard => 'IMP_STANDARD',
        :threshold_green => 'IMP_GREEN',
        :threshold_red => 'IMP_RED',
        :is_performance => lambda { |row| false },
      }.merge(fields)
    end

  end
end
