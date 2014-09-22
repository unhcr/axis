Visio.Mixins.Narratify =

  narratify: (figure) ->
    selectedDatum = figure.selectedDatum

    selectedDatum.on 'change:d', () =>
      d3.select(@el).select('.narrative').classed 'disabled', !selectedDatum.get('d')?

