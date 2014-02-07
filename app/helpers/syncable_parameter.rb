module SyncableParameter
  include SyncableHelpers

  def synced
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil

    render :json => resource.synced_models(
      synced_date,
      params[:join_ids],
      nil,
      params[:where]).as_json(params[:options])
  end

  def index
    render :json => resource.models(params[:join_ids], params[:page], params[:where]).as_json(params[:options])
  end

  def search
    query = ''
    query = params[:query] + '*' unless params[:query].nil? || params[:query].empty?
    render :json => resource.search_models(query)
  end
end
