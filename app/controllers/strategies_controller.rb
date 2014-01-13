class StrategiesController < ApplicationController
  def new
    @strategy = Strategy.new
    @operations = Operation.order(:name)
    @params = {
      :ppgs => Ppg.order(:name),
      :goals => Goal.order(:name),
      :problem_objectives => ProblemObjective.order(:objective_name),
      :rights_groups => RightsGroup.order(:name),
      :outputs => Output.order(:name),
      :indicators => Indicator.order(:name),
    }
  end

  def create
    s = Strategy.create(
      :name => params[:strategy][:name],
      :description => params[:strategy][:description])

    s.operations << Operation.find(params[:strategy][:operations]) if params[:strategy][:operations]
    s.plans << Plan.where(:operation_id => params[:strategy][:operations]) if params[:strategy][:operations]
    s.ppgs << Ppg.find((s.plans.map &:ppg_ids).flatten.uniq)

    if params[:strategy][:strategy_objectives]
      params[:strategy][:strategy_objectives].each do |strategy_objective|
        so = s.strategy_objectives.create(
          :name => strategy_objective[:name],
          :description => strategy_objective[:description])

        so.goals << Goal.find(strategy_objective[:goals]) if strategy_objective[:goals]
        so.outputs << Output.find(strategy_objective[:outputs]) if strategy_objective[:outputs]
        if strategy_objective[:problem_objectives]
          so.problem_objectives << ProblemObjective.find(strategy_objective[:problem_objectives])
        end

        if strategy_objective[:indicators]
          so.indicators << Indicator.find(strategy_objective[:indicators])
        end
      end
    end

    s.save


    render :json => { :strategy => s.as_json({ :include => { :strategy_objectives => true } }) }
  end
end
