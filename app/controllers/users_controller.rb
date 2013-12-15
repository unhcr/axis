class UsersController < ApplicationController

  def update
    render :json => {:success => false} and return unless user_signed_in?

    success = false
    success = current_user.update_attributes(params[:user]) if params[:id].to_i == current_user.id

    render :json => {:success => success}.merge(params[:user])
  end

end
