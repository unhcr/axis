module Parsers

  class IndicatorDataImpactParser < IndicatorDataParser

    def self.csvfields
      fields = super
      @csvfields = {
        :indicator_id => 'IMPINDICATOR_RFID',
        :id => 'IMPINDICATOR_ID',
        :yer => 'IMP_YEAR_END_VALUE',
        :myr => 'IMP_MID_YEAR_VALUE',
        :imp_target => 'IMP_IMP_TARGET',
        :comp_target => 'IMP_COMP_TARGET',
        :baseline => 'IMP_BASELINE',
        :standard => 'IMP_STANDARD',
        :threshold_red => 'IMP_RED',
        :threshold_green => 'IMP_GREEN',
        :is_performance => lambda { |row| false },
      }.merge(fields)
    end

    def self.selector
      [:id]
    end
  end
end
