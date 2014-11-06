class Visio.Legends.Map extends Visio.Legends.Base

  type: Visio.FigureTypes.MAP

  drawFigures: (svgEl) ->

    @drawCircleLegend svgEl

  circleData: =>
    algorithm = @figure.filters.get('algorithm').active()

    data = switch algorithm
      when 'selectedSituationAnalysis'
        [
          Visio.Algorithms.ALGO_RESULTS.success,
          Visio.Algorithms.ALGO_RESULTS.ok,
          Visio.Algorithms.ALGO_RESULTS.fail,
        ]
      else
        ['Higher', 'Lower']

    data.push 'Not Included'
    data


  circleText: (d) =>
    Visio.Utils.humanMetric d
