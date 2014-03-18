class Visio.Figures.Icsy extends Visio.Figures.Bar

  type: Visio.FigureTypes.ICSY

  initialize: (config) ->
    super config

    @x.domain [0, 1]

  filtered: (model) ->
    counts = model.get('counts')
    for key, val of counts
      counts[key] /= model.get 'total'
      counts[key] = 0 if _.isNaN counts[key]
    return d3.map(counts).entries()

