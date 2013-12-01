class IndicatorDataController < ApplicationController

  def index

    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      render :json => strategy.synced_data(params[:synced_date])
    else
      render :json => { :new => [], :updated => [], :deleted => [] }
    end

  end
end
