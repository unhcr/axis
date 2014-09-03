module Parsers
  class PopulationsParser < Parser
    MODEL = Population

    def self.csvfields
      @csvfields ||= {
        :value => 'VALUE',
        :ppg_code => 'PPG_CODE',
        :ppg_id => 'PPGID',
        :operation_id => 'OPERATIONID',
        :year => 'YEAR'
      }
    end

    def self.selector
      [:ppg_code, :ppg_id, :operation_id, :year]
    end

  end
end



