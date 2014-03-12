class StrategiesController < ApplicationController
  def create
    s = Strategy.create(
      :name => params[:name],
      :description => params[:description])


    s.update_nested params
    render :json => { :strategy => s.as_json({ :include => {
      :operations => true,
      :strategy_objectives => true } }) }
  end

  def update
    s = Strategy.find(params[:id])
    s.update_attributes(
      :name => params[:name],
      :description => params[:description])

    s.update_nested params

    render :json => { :strategy => s.as_json({ :include => {
      :operations => true,
      :strategy_objectives => true } }) }
  end

  def destroy
    s = Strategy.find(params[:id])
    s = s.destroy

    render :json => s
  end

end
