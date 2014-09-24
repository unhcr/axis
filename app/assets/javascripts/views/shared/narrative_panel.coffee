class Visio.Views.NarrativePanel extends Backbone.View

  template: HAML['shared/narrative_panel']

  initialize: ->

    $.subscribe 'narratify', @onNarratify

  render: ->

  timeout: 2000 # 2 seconds

  openClass: 'full-shift full-shift-right'

  onNarratify: (e, selectedDatum, $narrativeBtn) =>
    $('.page, #header').toggleClass @openClass
    $narrativeBtn.toggleClass 'open'


    if @isOpen()
      summaryParameters = selectedDatum.summaryParameters()
      @summarize(summaryParameters).done (resp) =>
        console.log resp
        if resp.success
          @fetchSummary resp.token, @timeout


  isOpen: =>
    $('.page, #header').hasClass @openClass


  summarize: (parameters) ->
    $.post('/narratives/summarize', parameters)

  fetchSummary: (token, timeout, attempts) ->
    timeout or= 2000
    nAttempts = 0

    doneFn = (resp) ->
      console.log resp
      nAttempts += 1
      if resp.success and resp.complete
        console.log resp.summary
      else
        console.log 'trying again'
        if !attempts? or nAttempts < attempts
          window.setTimeout (() -> $.get("/narratives/status/#{token}").done doneFn), timeout

    $.get("/narratives/status/#{token}").done doneFn


  close: ->
    $.unsubscribe 'narratify'
    @unbind()
    @remove()


