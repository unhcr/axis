module Parsers
  class OutputsParser < Parser
    MODEL = Output

    def self.csvfields
      @csvfields ||= {
        :id => 'ID',
        :name => 'NAME',
      }
    end

  end
end



