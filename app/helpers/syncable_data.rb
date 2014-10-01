module SyncableData
  include SyncableHelpers

  def index
    optimize = params[:optimize].present?

    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      if optimize
        render :json => strategy.data_optimized(resource).values[0][0] || []
      else
        render :json => strategy.data(resource, params[:limit], params[:where])
      end
    elsif params[:filter_ids]
      if optimize
        results = resource.models_optimized(params[:filter_ids],
                                           params[:limit],
                                           params[:where],
                                           params[:offset])
        values = results.values.present? ? results.values[0][0] : []
        render :json => values
      else
        render :json => resource.models(params[:filter_ids], params[:limit], params[:where])
      end
    else
      render :json => []
    end
  end
end

