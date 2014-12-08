class OperationsController < ParametersController

  def offices
    operation = Operation.find(params[:id])

    render :json => operation.offices.as_json
  end

  def head_offices
    operation = Operation.find(params[:id])

    render :json => operation.offices.head_offices.as_json
  end
end
