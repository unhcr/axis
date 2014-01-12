class IndicatorDataController < ApplicationController
  include SyncableData

  def index
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil

    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      render :json => strategy.synced_data(synced_date)
    else
      render :json => { :new => [], :updated => [], :deleted => [] }
    end

  end
end
