module SyncableData
  include SyncableHelpers

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
        render :json => resource.models_optimized(params[:filter_ids]).values[0][0]
      else
        render :json => resource.models(params[:filter_ids])
      end
    else
      render :json => []
    end
  end
end

