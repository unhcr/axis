module Parsers
  class NarrativesParser < Parser
    MODEL = Narrative

    def self.csvfields
      @csvfields ||= {
        :operation_id => 'OPERATIONID',
        :plan_id => 'PLANID',
        :year => 'PLANNINGYEAR',
        :goal_id => 'RFGOALID',
        :problem_objective_id => 'RFPROBLEMOBJECTIVEID',
        :output_id => 'RFOUTPUTID',
        :ppg_id => 'RFPPGID',
        :elt_id => 'ELTID',
        :plan_el_type => 'PLANELTYPE',
        :usertxt => 'USERTXT',
        :createusr => 'CREATEUSR',
        :id => 'REPORTID',
        :report_type => 'REPORT_TYPE',
      }

    end

    def self.selector
      [:id]
    end

  end
end

