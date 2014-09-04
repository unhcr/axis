module Parsers
  class GoalsParser < Parser
    MODEL = Goal

    def self.csvfields
      @csvfields ||= {
        :id => 'ID',
        :name => 'NAME',
      }
    end

    def self.selector
      [:id]
    end

  end

end


