class Visio.Views.NarrativePanel extends Backbone.View

  template: HAML['shared/narrative_panel']
  templateFullText: HAML['shared/narrative_panels/full_text']
  templateSummary: HAML['shared/narrative_panels/summary']

  textTypes:
    summary:
      name: 'summary'
      human: 'Summary'
    fullText:
      name: 'full_text'
      human: 'Full Text'

  textType: 'summary'

  timeout: 2000 # 2 seconds

  initialize: ->

    $.subscribe 'narratify-toggle-state', @onNarratifyStateToggle
    $.subscribe 'narratify-close', @onNarratifyClose
    $.subscribe 'narratify', @onNarratify

  events:
    'click .download': 'onDownload'
    'change input': 'onChangeTextType'

  render: ->

    @$el.html @template
      model: @model
      textTypes: @textTypes
      textType: @textType
    @renderTextType @textType
    @

  renderSummary: =>
    @$el.find('.panel-text').html @templateSummary
      model: @model

    summaryParameters = @model.summaryParameters()
    @summarize(summaryParameters).done (resp) =>
      if resp.success
        @fetchSummary resp.token, @timeout

  renderFullText: =>
    @$el.find('.panel-text').html @templateFullText
      model: @model

    summaryParameters = @model.summaryParameters()
    $panel = @$el.find(".panel .panel-full_text-#{@model.cid}")
    @fetchText(0,
      summaryParameters.ids,
      summaryParameters.reported_type,
      summaryParameters.year).done (resp) =>
        $panel.html ''
        _.each resp, (d) ->
          console.log d.usertxt
          $panel.append d.usertxt.replace(/\\n/g, '<br />')


  renderTextType: (textType) ->
    switch textType
      when @textTypes.summary.name
        @renderSummary()
      when @textTypes.fullText.name
        @renderFullText()

  openClass: 'shift-right'

  onChangeTextType: (e) =>
    @textType = $(e.currentTarget).val()

    @renderTextType @textType


  onNarratifyStateToggle: (e) =>
    $('.page').toggleClass @openClass
    $('.header-buttons .narrative').toggleClass 'open'

    $.publish 'close-filter-system' if @isOpen()

  onNarratifyClose: (e) =>
    $('.page').removeClass @openClass
    $('.header-buttons .narrative').removeClass 'open'

  onDownload: (e) =>
    params = @model.summaryParameters()

    options =
      name: "#{@model.name()} - #{params.year} - #{params.reported_type}"
      filter_ids: params.ids
      where: "USERTXT is not null AND
        report_type = '#{Visio.Utils.dbMetric(params.reported_type)}' AND
        year = '#{params.year}'"

    path = "/narratives/download.docx?#{$.param(options)}"

    Visio.Utils.redirect path

  onNarratify: (e, selectedDatum) =>
    @model = selectedDatum
    @render()



  isOpen: =>
    $('.page').hasClass @openClass

  summarize: (parameters) ->
    $.post('/narratives/summarize', parameters)

  fetchText: (page, ids, reported_type, year, limit = 30) ->
    options =
      limit: limit
      optimize: true
      filter_ids: ids
      where: "USERTXT is not null AND report_type = '#{Visio.Utils.dbMetric(reported_type)}' AND year = '#{year}'"
      offset: limit * page

    $.post('/narratives', options)


  fetchSummary: (token, timeout, attempts) ->
    timeout or= 2000
    nAttempts = 0
    $panel = @$el.find(".panel .panel-summary-#{@model.cid}")
    $panel.text 'thinking...!'

    doneFn = (resp) =>
      nAttempts += 1
      if resp.success and resp.complete
        console.log resp.summary
        $panel.text resp.summary
      else
        console.log 'trying again'
        if !attempts? or nAttempts < attempts
          window.setTimeout (() -> $.get("/narratives/status/#{token}").done doneFn), timeout

    $.get("/narratives/status/#{token}").done doneFn

  close: ->
    $.unsubscribe 'narratify-toggle-state'
    $.unsubscribe 'narratify-close'
    $.unsubscribe 'narratify'
    @unbind()
    @remove()


