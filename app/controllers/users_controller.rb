class UsersController < ApplicationController

  def update
    render :json => {:success => false} and return unless user_signed_in?

    success = false
    success = current_user.update_attributes(params[:user]) if params[:id].to_i == current_user.id

    render :json => {:success => success}.merge(params[:user])
  end

  def share
    render :json => {:success => false} and return unless user_signed_in?
    ids = params[:users].map { |u| u[:id] }

    success = current_user.share_strategy(User.find(ids), params[:strategy_id])

    render :json => { :success => success }
  end

  def search
    query = params[:query]

    users = User.where("login LIKE ?", "#{query}%").limit(10)

    render :json => users
  end

end
