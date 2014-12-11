# This is a module for data controllers. It provides an interface for retrieving data like budgets or exoenditures.

class DataController < ApplicationController
  before_filter :authenticate_user!

  include ControllerHelpers

  def index
    # Grab data based on a strategy
    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      render :json => strategy.data_optimized(resource).values[0][0] || []
    # Grab data based on ids (a set of operation, ppgs, goals, etc)
    elsif params[:filter_ids]
      results = resource.models_optimized(params[:filter_ids],
                                         params[:limit],
                                         params[:where],
                                         params[:offset])
      values = results.values.present? ? results.values[0][0] : []
      render :json => values
    # Return nothing if nothing is supplied (returning everything isn't feasible). In the future
      # it could return a page of data.
    else
      render :json => []
    end
  end
end


