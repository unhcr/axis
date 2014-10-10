class Visio.Legends.Absy extends Visio.Legends.Base

  type: Visio.FigureTypes.ABSY

  drawFigures: (svgEl) ->
    @drawCircleLegend svgEl
    svgEl

  circleData: =>
    ['Within Strategy', 'Outside Strategy']
