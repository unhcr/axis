class NarrativesController < ApplicationController

  def summarize

    ids = params[:ids] || {}
    report_type = params[:report_type] || 'Mid Year Report'
    year = params[:year] || 2013

    token = Narrative.summarize ids, report_type, year

    render :json => {
      :success => true,
      :message => 'Summarizing article',
      :token => token
    }

  end

  def status
    token = params[:token]

    summary = Redis.current.get(token)

    render :json => {
      :success => true,
      :complete => !summary.nil?,
      :summary => summary
    }
  end
end
