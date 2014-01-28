class ExportModulesController < ApplicationController
  before_filter :authenticate_user!

  def create
    export_module = ExportModule.new(params[:export_module])
    export_module.user = current_user
    export_module.save

    render :json => export_module
  end

  def index
    render :json => current_user.export_modules
  end
end
