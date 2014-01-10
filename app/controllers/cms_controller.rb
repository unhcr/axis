class CmsController < ApplicationController

  def strategies
    @strategies = Strategy.all
    render :layout => 'cms'
  end
end
