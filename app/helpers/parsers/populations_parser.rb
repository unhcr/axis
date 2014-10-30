module Parsers
  class PopulationsParser < Parser
    MODEL = Population

    def self.csvfields
      @csvfields ||= {
        :value => 'POC',
        :ppg_code => 'PPG_CODE',
        :ppg_id => 'ORIGPOPGROUP_ID',
        :element_id => 'ELEMENT_ID',
        :element_type => 'ELEMENT_TYPE',
        :year => 'YEAR'
      }
    end

    def self.selector
      [:ppg_code, :ppg_id, :element_id, :element_type, :year]
    end

  end
end



