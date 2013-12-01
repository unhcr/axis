class IndicatorDataController < ApplicationController

  def index

    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      render :json => strategy.synced_data(synced_date)
    else
      render :json => []
    end

  end
end
