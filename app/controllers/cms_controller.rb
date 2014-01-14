class CmsController < ApplicationController

  def strategies
    @strategies = Strategy.includes(:operations, :strategy_objectives).all
    render :layout => 'cms'
  end
end
