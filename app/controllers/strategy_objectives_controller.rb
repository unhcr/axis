class StrategyObjectivesController < ApplicationController
  def index
    render :json => StrategyObjective.all
  end
end

