module Parsers
  class ProblemObjectivesParser < Parser
    MODEL = ProblemObjective

    def self.csvfields
      @csvfields ||= {
        :id => 'ID',
        :objective_name => 'OBJECTIVENAME',
        :problem_name => 'PROBLEMNAME',
      }
    end

  end
end




