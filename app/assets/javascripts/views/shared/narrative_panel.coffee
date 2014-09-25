class Visio.Views.NarrativePanel extends Backbone.View

  template: HAML['shared/narrative_panel']

  initialize: ->

    $.subscribe 'narratify-toggle-state', @onNarratifyStateToggle
    $.subscribe 'narratify', @onNarratify

  events:
    'click .download': 'onDownload'

  render: ->

    @$el.html @template()
    @

  timeout: 2000 # 2 seconds

  openClass: 'shift-right'

  onNarratifyStateToggle: (e) =>
    $('.page').toggleClass @openClass
    $('.header-buttons .narrative').toggleClass 'open'

  onDownload: (e) =>
    params = @model.summaryParameters()

    options =
      name: "#{@model.name()} - #{params.year} - #{params.reported_type}"
      filter_ids: params.ids
      where: "USERTXT is not null AND report_type = '#{Visio.Utils.dbMetric(params.reported_type)}' AND year = '#{params.year}'"

    window.location = "/narratives/download.docx?#{$.param(options)}"

  onNarratify: (e, selectedDatum) =>
    @model = selectedDatum

    summaryParameters = @model.summaryParameters()
    @summarize(summaryParameters).done (resp) =>
      console.log resp
      if resp.success
        @fetchSummary resp.token, @timeout

    $panel = @$el.find('.panel .full-text')
    @fetchText(0,
      summaryParameters.ids,
      summaryParameters.reported_type,
      summaryParameters.year).done (resp) =>
        $panel.html ''
        _.each resp, (d) ->
          console.log d.usertxt
          $panel.append d.usertxt.replace(/\\n/g, '<br />')

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
    $panel = @$el.find('.panel .summary')
    $panel.text 'thinking...!'

    doneFn = (resp) =>
      console.log resp
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
    $.unsubscribe 'narratify'
    @unbind()
    @remove()


