class StrategiesController < ApplicationController
  def create
    s = Strategy.create(
      :name => params[:strategy][:name],
      :description => params[:strategy][:description])

    s.operations = Operation.find(params[:strategy][:operations]) if params[:strategy][:operations]
    s.plans = Plan.where(:operation_id => params[:strategy][:operations]) if params[:strategy][:operations]
    s.ppgs = Ppg.find((s.plans.map &:ppg_ids).flatten.uniq)

    if params[:strategy][:strategy_objectives]
      params[:strategy][:strategy_objectives].each do |strategy_objective|
        so = s.strategy_objectives.create(
          :name => strategy_objective[:name],
          :description => strategy_objective[:description])

        so.goals = Goal.find(strategy_objective[:goals]) if strategy_objective[:goals]
        so.outputs = Output.find(strategy_objective[:outputs]) if strategy_objective[:outputs]
        if strategy_objective[:problem_objectives]
          so.problem_objectives = ProblemObjective.find(strategy_objective[:problem_objectives])
        end

        if strategy_objective[:indicators]
          so.indicators = Indicator.find(strategy_objective[:indicators])
        end
      end
    end

    s.save


    render :json => { :strategy => s.as_json({ :include => { :strategy_objectives => true } }) }
  end

  def update
    s = Strategy.find(params[:id])

    s.update_attributes(
      :name => params[:strategy][:name],
      :description => params[:strategy][:description])


    s.operations = Operation.find(params[:strategy][:operations]) if params[:strategy][:operations]
    s.plans = Plan.where(:operation_id => params[:strategy][:operations]) if params[:strategy][:operations]
    s.ppgs = Ppg.find((s.plans.map &:ppg_ids).flatten.uniq)

    s.strategy_objectives.clear
    if params[:strategy][:strategy_objectives]
      params[:strategy][:strategy_objectives].each do |strategy_objective|
        so = s.strategy_objectives.create(
          :name => strategy_objective[:name],
          :description => strategy_objective[:description])

        if strategy_objective[:goals]
          goal_ids = strategy_objective[:goals].map do |goalOrId|
            goalOrId.is_a?(Hash) ? goalOrId[:id] : goalOrId
          end
          so.goals = Goal.find(goal_ids)
        end
        if strategy_objective[:outputs]
          output_ids = strategy_objective[:outputs].map do |outputOrId|
            outputOrId.is_a?(Hash) ? outputOrId[:id] : outputOrId
          end
          so.outputs = Output.find(output_ids)
        end
        if strategy_objective[:problem_objectives]
          po_ids = strategy_objective[:problem_objectives].map do |poOrId|
            poOrId.is_a?(Hash) ? poOrId[:id] : poOrId
          end
          so.problem_objectives = ProblemObjective.find(po_ids)
        end

        if strategy_objective[:indicators]
          indicator_ids = strategy_objective[:indicators].map do |indicatorOrId|
            indicatorOrId.is_a?(Hash) ? indicatorOrId[:id] : indicatorOrId
          end
          so.indicators = Indicator.find(indicator_ids)
        end
        so.save
      end
    end

    s.save


    render :json => { :strategy => s.as_json({ :include => { :strategy_objectives => true } }) }
  end

  def destroy
    s = Strategy.find(params[:id])
    s = s.destroy

    render :json => s
  end
end
