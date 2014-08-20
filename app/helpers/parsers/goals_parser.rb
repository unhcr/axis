module Parsers
  class GoalsParser < Parser
    MODEL = Goal

    def self.csvfields
      @csvfields ||= {
        :id => 'ID',
        :name => 'NAME',
      }
    end

  end
end


