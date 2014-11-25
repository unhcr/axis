# Figure for providing the axis of the overview dashboard figure
class Visio.Figures.Axis extends Visio.Figures.Base

  type: Visio.FigureTypes.AXIS

  initialize: (config) ->

    super config
    @scale = d3.scale.linear()
      .range([0, @adjustedHeight])
      .domain([1, 0])

    @axis = d3.svg.axis()
      .scale(@scale)
      .orient('left')
      .ticks(5)
      .tickFormat(Visio.Formats.PERCENT)

    @g.append('g')
      .attr('class', 'axis')
      .attr('transform', 'translate(0,0)')

  render: ->
    @g.select('.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@axis)
    @
