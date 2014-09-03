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
    optimize = params[:optimize].present?
    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      if optimize
        render :json => strategy.data_optimized(resource).values[0][0]
      else
        render :json => strategy.data(resource)
      end
    elsif params[:filter_ids]
      if optimize
        render :json => resource.synced_models_optimized(params[:filter_ids]).values[0][0]
      else
        render :json => resource.synced_models(params[:filter_ids])[:new]
      end
    else
      render :json => []
    end
  end
end

