class StrategyObjectivesController < ApplicationController
  def index
    results = nil
    if params[:where].present? and params[:where][:strategy_id].present?
      results = StrategyObjective.where(params[:where])
    else
      results = StrategyObjective.global_strategy_objectives.where(params[:where])
    end

    render :json => results
  end

  def search
    query = ''
    query = sanitize_query(params[:query]) + '*' unless params[:query].nil? || params[:query].empty?
    render :json => StrategyObjective.search_models(query)
  end

  def show
    model = StrategyObjective.find(params[:id])
    if model
      render :json => model.as_json(params[:options])
    else
      render :json => {}
    end
  end
end

