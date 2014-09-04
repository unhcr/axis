module Parsers
  class OperationsParser < Parser
    MODEL = Operation

    def self.csvfields
      @csvfields ||= {
        :id => 'OPERATIONID',
        :name => 'NAME',
      }
    end

    def self.selector
      [:id]
    end
  end
end




