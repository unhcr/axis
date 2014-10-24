class StrategyObjectivesController < ApplicationController
  def index
    results = StrategyObjective
    results = results.global_strategy_objectives if params[:global_only].present?
    results = results.where(params[:where])

    render :json => results
  end

  def search
    query = ''
    query = sanitize_query(params[:query]) + '*' unless params[:query].nil? || params[:query].empty?
    render :json => StrategyObjective.search_models(query, { :global_only => params[:global_only] })
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

