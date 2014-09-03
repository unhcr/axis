module Parsers
  class PositionsParser < Parser
    MODEL = Position
    def self.csvfields
      @csvfields ||= {
        :id => 'PLANNEDPOSITIONID',
        :grade => 'POSITIONGRADE',
        :title => 'POSITIONTITLE',
        :incumbent => 'INCUMBENT_NAME',
        :office_id => 'OFFICEID',
        :existing => lambda { |row| row['EXISTINGPOSITION'] == 'Y' },
        :contract_type => 'POSITIONTYPE',
        :parent_position_id => 'REPORTSTO_ID',
        :plan_id => 'PLANID',
        :operation_id => 'OPERATIONID'
      }
    end
    def self.selector
      [:id]
    end
  end
end
