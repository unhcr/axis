class Visio.Views.NarrativePanel extends Backbone.View

  template: HAML['shared/narrative_panel']

  initialize: ->

    $.subscribe 'narratify-toggle-state', @onNarratifyStateToggle
    $.subscribe 'narratify', @onNarratify

  render: ->

    @$el.html @template()
    @

  timeout: 2000 # 2 seconds

  openClass: 'shift-right'

  onNarratifyStateToggle: (e) =>
    $('.page').toggleClass @openClass
    $('.header-buttons .narrative').toggleClass 'open'

  onNarratify: (e, selectedDatum) =>

    summaryParameters = selectedDatum.summaryParameters()
    @summarize(summaryParameters).done (resp) =>
      console.log resp
      if resp.success
        @fetchSummary resp.token, @timeout


  isOpen: =>
    $('.page').hasClass @openClass


  summarize: (parameters) ->
    $.post('/narratives/summarize', parameters)

  fetchSummary: (token, timeout, attempts) ->
    timeout or= 2000
    nAttempts = 0
    $panel = @$el.find('.panel')
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


