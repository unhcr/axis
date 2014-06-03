class CmsController < ApplicationController

  before_filter :authenticate_user!

  def strategies
    @is_personal = params[:is_personal].present?

    render_403 and return if not @is_personal and not current_user.admin

    @strategies = Strategy.includes(:operations, :strategy_objectives, :ppgs)

    if @is_personal
      @strategies = @strategies.where(:user_id => current_user.id)
    else
      @strategies = @strategies.where(:user_id => nil)
    end
    render :layout => 'cms'
  end
end
