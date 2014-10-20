module SyncableData
  include SyncableHelpers

  def index
    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      render :json => strategy.data_optimized(resource).values[0][0] || []
    elsif params[:filter_ids]
      results = resource.models_optimized(params[:filter_ids],
                                         params[:limit],
                                         params[:where],
                                         params[:offset])
      values = results.values.present? ? results.values[0][0] : []
      render :json => values
    else
      render :json => []
    end
  end
end

