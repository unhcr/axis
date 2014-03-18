class Visio.Figures.Bar extends Visio.Figures.Base

  initialize: (config) ->
    @orientation = config.orientation or 'left'


    super config

    @x = d3.scale.linear()
      .range([0, @adjustedWidth])

    @y = d3.scale.linear()
      .domain([0, @adjustedHeight])
      .range([@adjustedHeight, 0])

  render: ->

    # Choose collection over model
    filtered = @filtered(@collection || @model)

    @barWidth = switch @orientation
      when 'top', 'bottom' then @adjustedWidth / filtered.length
      when 'right', 'left' then @adjustedHeight / filtered.length

    @barWidth = 0 if _.isNaN @barWidth

    @bars = @g.selectAll('.bar').data(filtered)
    @bars.enter().append('rect')
    @bars.attr('class', (d) ->
      ['bar', d.key].join ' ' )

    switch @orientation
      when 'bottom', 'top'
        @bars.transition().duration(Visio.Durations.FAST)
          .attr('y', (d) => @y(d.value))
          .attr('x', (d, i) => @x(i * @barWidth) - @barWidth)
          .attr('height', (d) => @x(0) - @x(d.value))
          .attr('width', @barWidth)
      when 'right'
        @bars.transition().duration(Visio.Durations.FAST)
          .attr('x', (d) => @x(d.value))
          .attr('y', (d, i) => @y(i * @barWidth) - @barWidth)
          .attr('width', (d) => @x(0) - @x(d.value))
          .attr('height', () => @barWidth)
      when 'left'
        @bars.transition().duration(Visio.Durations.FAST)
          .attr('x', (d) => @x(0))
          .attr('y', (d, i) => @y(i * @barWidth) - @barWidth)
          .attr('width', (d) => @x(d.value))
          .attr('height', () => @barWidth)

    @bars.exit().remove()
    @

