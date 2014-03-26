class CmsController < ApplicationController

  def strategies
    @strategies = Strategy.includes(:operations, :strategy_objectives, :ppgs).all
    render :layout => 'cms'
  end
end
