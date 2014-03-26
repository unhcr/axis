module SyncableData
  include SyncableHelpers

  def synced
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil
    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])
      render :json => strategy.synced(resource, synced_date)
    elsif params[:filter_ids]
      render :json => resource.synced_models(params[:filter_ids], synced_date)
    else
      render :json => { :new => [], :updated => [], :deleted => [] }
    end
  end

  def index
    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])
      render :json => strategy.synced(resource)[:new]
    elsif params[:filter_ids]
      render :json => resource.synced_models(params[:filter_ids])[:new]
    else
      render :json => []
    end
  end
end

