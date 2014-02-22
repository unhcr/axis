class Visio.Figures.Spark extends Visio.Figures.Base

  type: Visio.FigureTypes.SPARK

  initialize: (config) ->
    @barWidth = config.barWidth || 10
    config.height = (@barWidth * 4) + config.margin.top + config.margin.bottom

    super config

    @x = d3.scale.linear()
      .domain([50, 0])
      .range([0, @adjustedWidth])

    @y = d3.scale.linear()
      .domain([0, 40])
      .range([@adjustedHeight, 0])

    @negativeLength = 2
    @margin.right = @negativeLength

  render: ->

    filtered = @filtered @model

    @bars = @g.selectAll('.bar').data(filtered)
    @bars.enter().append('rect')
    @bars.attr('class', (d) ->
      ['bar', d.key].join ' ' )
    @bars.transition().duration(Visio.Durations.FAST)
      .attr('x', (d) => @x(d.value))
      .attr('y', (d, i) => @y(i * @barWidth) - @barWidth)
      .attr('width', (d) => if d.value then @x(0) - @x(d.value) else @negativeLength)
      .attr('height', @barWidth)

    @bars.exit().remove()
    @

  filtered: (model) ->
    counts = model.selectedSituationAnalysis().counts

    return d3.map(counts).entries()
