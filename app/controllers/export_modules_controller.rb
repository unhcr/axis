class ExportModulesController < ApplicationController
  before_filter :authenticate_user!

  def create
    export_module = ExportModule.new(params[:export_module])
    export_module.user = current_user
    export_module.save

    render :json => export_module
  end

  def update
    export_module = current_user.export_modules.find(params[:id])
    render :json => {} unless export_module

    export_module.update_attributes params[:export_module]
    export_module.save

    render :json => export_module
  end

  def index
    render :json => current_user.export_modules
  end

  def pdf
    @export_module = ExportModule.find(current_user.export_modules.find(params[:id]))
    render :layout => 'report'
  end

  def email
    export_module = ExportModule.find(current_user.export_modules.find(params[:id]))
    export_module.email "#{request.protocol}#{request.host_with_port}", request.cookies

    render :json => { :success => true }
  end
end
