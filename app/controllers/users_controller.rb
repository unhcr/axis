class UsersController < ApplicationController

  def update
    render :json => {:success => false} and return if !user_signed_in? || !current_user.admin

    success = false
    success = current_user.update_attributes(params[:user]) if params[:id].to_i == current_user.id

    render :json => {:success => success}.merge(params[:user])
  end

  def admin
    render :json => {:success => false} and return if !user_signed_in? || !current_user.admin

    # Turn off current admin
    User.where(:admin => true).update_all :admin => false

    # Turn on passed users
    users = User.where :id => params[:users].map { |u| u[:id] }
    users.update_all :admin => true

    render :json => {:success => true, :users => users }
  end

  def share
    render :json => {:success => false} and return unless user_signed_in?

    ids = []
    ids = params[:users].map { |u| u[:id] } unless params[:users].nil?


    success = current_user.share_strategy(User.find(ids), params[:strategy_id])

    render :json => { :success => success }
  end

  def search
    query = params[:query]

    users = User.where("login LIKE ?", "#{query}%").limit(10)

    render :json => users
  end

end
