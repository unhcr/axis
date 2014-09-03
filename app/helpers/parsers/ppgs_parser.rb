module Parsers
  class PpgsParser < Parser
    MODEL = Ppg

    def self.csvfields
      @csvfields ||= {
        :id => 'ORIGPOPGROUP_ID',
        :name => 'POPULATIONGROUPNAME',
        :population_type => 'POPGROUPTYPE',
        :population_type_id => 'POPGROUPTYPEID',
        :msrp_code => 'MSRPCODE',
        :operation_name => 'OPERATIONNAME'
      }
    end

    def self.selector
      [:id]
    end

  end

end


