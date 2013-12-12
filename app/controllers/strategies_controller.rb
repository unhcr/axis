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
    s = Strategy.new(:name => params[:strategy][:name])
    s.operations << Operation.find(params[:operations].keys) if params[:operations]
    s.plans << Plan.where(:operation_id => params[:operations].keys) if params[:operations]
    s.ppgs << Ppg.find(params[:ppgs].keys) if params[:ppgs]
    s.goals << Goal.find(params[:goals].keys) if params[:goals]
    s.problem_objectives << ProblemObjective.find(params[:problem_objectives].keys) if params[:problem_objectives]
    s.outputs << Output.find(params[:outputs].keys) if params[:outputs]
    s.indicators << Indicator.find(params[:indicators].keys) if params[:indicators]
    s.save

    redirect_to action: :new and return
  end
end
