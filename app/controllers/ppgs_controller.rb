class PpgsController < ApplicationController
  def index
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil

    # Must be a nested route
    if params[:plan_id]
      plan = Plan.find(params[:plan_id])
      render :json => plan.ppgs.as_json
    else
      render :json => Ppg.synced_models(synced_date, nil, 20, params[:where]).as_json
    end
  end
end
