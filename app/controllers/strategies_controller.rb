class StrategiesController < ApplicationController
  before_filter :authenticate_user!

  def create
    render_403 and return if not params[:is_personal] and not current_user.admin

    s = Strategy.create(
      :name => params[:name],
      :description => params[:description])



    s.user = current_user if params[:is_personal]
    s.save

    s.update_nested params
    s.save

    render :json => { :strategy => s.as_json({ :include => {
      :ppgs => true,
      :operations => true,
      :strategy_objectives => true } }) }
  end

  def update
    s = Strategy.find(params[:id])
    s.update_attributes(
      :name => params[:name],
      :description => params[:description])

    s.update_nested params
    s.reload

    render :json => { :strategy => s.as_json({ :include => {
      :operations => true,
      :ppgs => true,
      :strategy_objectives => true } }) }
  end

  def globalize
    render_403 and return unless current_user.admin

    s = Strategy.find(params[:id])
    s.make_global
    s.reload

    render :json => { :success => true, :strategy => s.as_json({ :include => {
      :operations => true,
      :ppgs => true,
      :strategy_objectives => true } }) }
  end

  def normalize
    render_403 and return unless current_user.admin

    Strategy.all.each do |s|
      s.normalize
    end

    render :json => { :success => true }
  end

  def destroy
    s = Strategy.find(params[:id])
    s = s.destroy

    render :json => s
  end

  def download
    s = Strategy.find(params[:id])

    workbook = s.to_workbook

    send_data workbook.to_stream.read,
      :filename => "#{s.name} -- #{Time.now}",
      :disposition => 'inline',
      :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

end
