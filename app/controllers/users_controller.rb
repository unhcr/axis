class UsersController < ApplicationController

  def update
    render :json => {:success => false} and return if !user_signed_in? || !current_user.admin

    success = false
    success = current_user.update_attributes(params[:user]) if params[:id].to_i == current_user.id

    render :json => {:success => success}.merge(params[:user])
  end

  def admin
    render :json => {:success => false} and return if !user_signed_in? || !current_user.admin

    current_admin = User.where(:admin => true)
    users = User.where :id => params[:users].map { |u| u[:id] }

    new_admin = users - current_admin

    # Turn off current admin
    current_admin.update_all :admin => false

    # Turn on passed users
    users.update_all :admin => true

    host = request.host_with_port
    UserMailer.admin_email(current_user, new_admin, host).deliver

    render :json => {:success => true, :users => users }
  end

  def share
    render :json => {:success => false} and return unless user_signed_in?

    ids = []
    ids = params[:users].map { |u| u[:id] } unless params[:users].nil?

    strategy = current_user.strategies.find(params[:strategy_id])

    new_users = current_user.share_strategy(User.find(ids), strategy)

    host = request.host_with_port
    UserMailer.share_email(strategy, current_user, new_users, host).deliver

    render :json => { :success => !new_users.nil? }
  end

  def search
    query = params[:query]

    users = User.where("login LIKE ?", "#{query}%").limit(10)

    render :json => users
  end

end
