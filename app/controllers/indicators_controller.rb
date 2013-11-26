class IndicatorsController < ApplicationController

  def index
    require 'pry'; binding.pry
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil

    render :json => Indicator.synced_models(synced_date, nil, 20, params[:where]).as_json
  end
end
