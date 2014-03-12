class ExportModulesController < ApplicationController
  before_filter :authenticate_user!

  def create
    Rails.logger.info `env`
    export_module = ExportModule.new(params[:export_module])
    export_module.user = current_user
    export_module.save

    render :json => export_module
  end

  def index
    render :json => current_user.export_modules
  end

  def pdf
    Rails.logger.info `env`
    @export_module = ExportModule.find(current_user.export_modules.find(params[:id]))
    render :layout => 'report'
  end
end
