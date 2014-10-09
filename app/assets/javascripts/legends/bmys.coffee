class Visio.Legends.BmySummary extends Visio.Legends.Base

  type: Visio.FigureTypes.BMY_SUMMARY

  drawFigures: (svgEl) ->

    @drawCircleLegend svgEl


  circleData: ->
    ['Total', 'Breakdown']

