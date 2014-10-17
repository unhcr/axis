module SyncableData
  include SyncableHelpers

  def index
    user_id = params[:user_id]

    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      user_id = current_user.id unless strategy.user.nil?
      render :json => strategy.data_optimized(resource, nil, nil,  user_id).values[0][0] || []
    elsif params[:filter_ids]
      results = resource.models_optimized(params[:filter_ids],
                                         params[:limit],
                                         params[:where],
                                         params[:offset], user_id)
      values = results.values.present? ? results.values[0][0] : []
      render :json => values
    else
      render :json => []
    end
  end
end

