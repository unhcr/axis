class StrategyObjectivesController < ApplicationController
  def index
    render :json => StrategyObjective.where(params[:where]).all
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

