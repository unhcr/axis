module SyncableParameter
  include SyncableHelpers

  def index
    render :json => resource.models(params[:join_ids], params[:page], params[:where]).as_json(params[:options])
  end

  def search
    query = ''
    query = sanitize_query(params[:query]) + '*' unless params[:query].nil? || params[:query].empty?
    render :json => resource.search_models(query)
  end

  def show
    model = resource.find(params[:id])
    if model
      render :json => model.as_json(params[:options])
    else
      render :json => {}
    end
  end
end
