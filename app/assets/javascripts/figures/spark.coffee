class Visio.Figures.Spark extends Visio.Figures.Base

  type: Visio.FigureTypes.SPARK

  initialize: (config) ->
    @barWidth = config.barWidth || 10
    config.height = @barWidth * 4

    super config

    @x = d3.scale.linear()
      .domain([50, 0])
      .range([0, @width])

    @y = d3.scale.linear()
      .domain([0, 40])
      .range([@height, 0])

    @negativeLength = 2
    @margin.right = @negativeLength

  render: ->

    filtered = @filtered @data

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

  filtered: (data) ->
    counts = {}

    _.each data, (d) ->
      c = d.selectedSituationAnalysis().counts
      for key, val of c
        counts[key] = 0 unless counts[key]?
        counts[key] += c[key]

    return d3.map(counts).entries()
