class Visio.Legends.Icmy extends Visio.Legends.Base

  type: Visio.FigureTypes.ICMY

  drawFigures: (svgEl) ->

    @drawCircleLegend svgEl

  circleData: =>
    switch @figure.filters.get('algorithm').active()
      when 'selectedPerformanceAchievement', 'selectedImpactAchievement'
        _.map Visio.Algorithms.THRESHOLDS, (d) -> d.value
      when 'selectedSituationAnalysis'
        _.map Visio.Algorithms.CRITICALITIES, (d) -> d.value

  circleText: (d) =>
    Visio.Utils.humanMetric(d).toUpperCase()
