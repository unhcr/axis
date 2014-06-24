module Parsers
  class OfficesParser < Parser
    MODEL = Office

    def self.csvfields
      @csvfields ||= {
        :id => 'PRJOFFICEID',
        :status => 'STATUS',
        :name => 'OFFICENAME',
        :parent_office_id => 'PARENTOFFICEID',
        :plan_id => 'OPERATIONPLAN_ID',
        :operation_id => 'OPERATIONID'
      }
    end

  end
end

