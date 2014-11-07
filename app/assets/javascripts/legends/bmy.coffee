class Visio.Legends.Bmy extends Visio.Legends.Base

  type: Visio.FigureTypes.BMY

  drawFigures: (svgEl) ->

    @drawCircleLegend svgEl

  circleData: () =>
    groupBy = @figure.filters.get('group_by').active()
    switch groupBy
      when 'budget_type'
        _.keys Visio.Budgets
      when 'pillar'
        _.keys Visio.Pillars
      when 'scenario'
        _.keys Visio.Scenarios

  circleText: (d) =>
    Visio.Budgets[d] or Visio.Pillars[d] or Visio.Scenarios[d]
