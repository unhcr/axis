Visio.Mixins.Narratify =

  narratify: (figure) ->
    @selectedDatum = selectedDatum = figure.selectedDatum

    selectedDatum.on 'change:d', () =>
      # This works based on ordering of accordion when selecting summary ele. Should change to have figure
      # ids attached to buttons

      narrativeBtn = d3.select(@el).select('.narrative')
      narrativeBtn.classed 'disabled', !selectedDatum.get('d')?

      # If it's already open, let's just load up the next narrative
      if @isNarrativePanelOpen()
        $.publish 'narratify', [@selectedDatum]


    @$el.on 'click', '.narrative', @onClickNarrativeBtn.bind(@)

    previousClose = @close

    @close = ->
      $narrativeBtn.off 'click'
      $overlay.remove()
      previousClose.apply @, arguments

  isNarrativePanelOpen: ->
    Visio.router.narrativePanel.isOpen()

  onClickNarrativeBtn:  (e) ->
    e.stopPropagation()
    $target = $(e.currentTarget)
    return if $target.hasClass 'disabled'

    $.publish 'narratify-toggle-state'

    if @isNarrativePanelOpen()
      $.publish 'narratify', [@selectedDatum]
