# The export module controller allows the client to create export modules. Once an export
# module has been created, it can then be used to create pdfs or any other exportation that
# will be developed in the report.
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

  # Renders the html of the export module for the PDF. Utilized by the Shrimp library to transform
  # that html to PDF.
  def pdf
    @export_module = ExportModule.find(current_user.export_modules.find(params[:id]))
    render :layout => 'report'
  end

  def email
    export_module = ExportModule.find(current_user.export_modules.find(params[:id]))
    export_module.email "#{request.protocol}#{request.host_with_port}", request.cookies, self.current_user.email

    render :json => { :success => true, :email => self.current_user.email }
  end
end
