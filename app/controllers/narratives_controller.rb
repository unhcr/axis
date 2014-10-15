class NarrativesController < ApplicationController
  include SyncableData

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

  def search
    query = ''
    query = sanitize_query(params[:query]) + '*' unless params[:query].nil? || params[:query].empty?
    render :json => Narrative.search_models(query,
                                            params[:filter_ids],
                                            params[:report_type],
                                            params[:year],
                                            { :page => params[:page] })
  end

  def to_docx
    @name = params[:name]
    @name = "Narrative Report" if @name.nil? or @name.empty?
    params[:filter_ids] = JSON.parse(params[:filter_ids]) if params[:filter_ids].present?

    @narratives = resource.models_optimized(params[:filter_ids],
                                            nil,
                                            params[:where],
                                            params[:offset]).values[0][0] || []
    @narratives = JSON.parse(@narratives)

    html = view_context.render :template => 'layouts/narrative_word'
    filename = "#{@name}.docx"
    file = Htmltoword::Document.create(html, filename)

    send_data File.read(file.path),
      :filename => filename,
      :disposition => 'attachment',
      :type => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'

  end

  def total_characters
    render :json => {
        :total_characters => Narrative.total_characters(params[:filter_ids]).values[0][0] || 0
      }
  end
end
