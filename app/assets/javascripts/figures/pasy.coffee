class Visio.Figures.Pasy extends Visio.Figures.Bar

  type: Visio.FigureTypes.PASY

  initialize: (config) ->
    super config

    @variable.domain [0, 1]

  filtered: (model) ->
    counts = model.get('counts')
    for key, val of counts
      counts[key] /= model.get 'total'
      counts[key] = 0 if _.isNaN counts[key]
    return d3.map(counts).entries()


