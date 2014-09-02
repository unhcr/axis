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

  end
end



