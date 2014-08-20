module Parsers
  class OperationsParser < Parser
    MODEL = Operation

    def self.csvfields
      @csvfields ||= {
        :id => 'OPERATIONID',
        :name => 'NAME',
      }
    end

  end
end




