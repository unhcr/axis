Visio.Mixins.Narratify =

  narratify: (figure) ->
    @selectedDatum = selectedDatum = figure.selectedDatum

    selectedDatum.on 'change:d', () =>
      d3.select(@el).select('.narrative').classed 'disabled', !selectedDatum.get('d')?

    @$el.on 'click', '.narrative', @onClickNarrativeBtn.bind(@)

    previousClose = @close

    @close = ->
      $narrativeBtn.off 'click'
      $overlay.remove()
      previousClose.apply @, arguments

  onClickNarrativeBtn:  (e) ->
    e.stopPropagation()
    $target = $(e.currentTarget)
    return if $target.hasClass 'disabled'

    $.publish 'narratify', [@selectedDatum, $target]
