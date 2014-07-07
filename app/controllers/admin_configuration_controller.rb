class AdminConfigurationController < ApplicationController

  before_filter :authenticate_user!

  def edit
    render_403 and return unless current_user.admin
    @configuration = AdminConfiguration.first
    render :edit
  end

  def update
    render_403 and return unless current_user.admin
    @configuration = AdminConfiguration.first
    @configuration.update_attributes params[:admin_configuration]

    render :show
  end

  def show
    render_403 and return unless current_user.admin
    @configuration = AdminConfiguration.first

    render :show
  end
end
