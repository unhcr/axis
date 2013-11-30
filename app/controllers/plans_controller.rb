class PlansController < ApplicationController

  def index
    year = params[:year] || Time.now.year
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil
    options = {
      :include => {
        :counts => true
      }
    }

    params[:where] ||= {}
    params[:where][:year] = year

    render :json => Plan.synced_models(synced_date, params[:join_ids], nil, params[:where]).as_json(options)
  end
end
