class PlansController < ApplicationController

  def index
    year = params[:year]
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil


    params[:where] ||= {}
    if year
      params[:where][:year] = year
    end

    render :json => Plan.synced_models(synced_date, params[:join_ids], nil, params[:where]).as_json(params[:options])
  end
end
