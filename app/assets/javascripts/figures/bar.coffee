class Visio.Figures.Bar extends Visio.Figures.Base

  initialize: (config) ->
    @orientation = config.orientation or 'left'


    super config

    @x = d3.scale.linear()

    switch @orientation
      when 'left', 'top', 'bottom'
        @x.range [0, @adjustedWidth]
      when 'right'
        @x.range [@adjustedWidth, 0]

    @y = d3.scale.linear()
      .domain([0, @adjustedHeight])
      .range([@adjustedHeight, 0])

    @zeroPadding = switch @orientation
      when 'top', 'bottom' then @adjustedHeight * .03
      when 'left', 'right' then @adjustedWidth * .03



  render: ->

    # Choose collection over model
    filtered = @filtered(@collection || @model)

    @barWidth = switch @orientation
      when 'top', 'bottom' then @adjustedWidth / filtered.length
      when 'right', 'left' then @adjustedHeight / filtered.length

    @barWidth = 0 if _.isNaN @barWidth

    @barsContainer = @g.append('g')
      .attr('transform', "translate(#{@zeroPadding + 2}, 0)")

    @bars = @barsContainer.selectAll('.bar').data(filtered)
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
      when 'left'
        @bars.transition().duration(Visio.Durations.FAST)
          .attr('x', (d) => @x(0))
          .attr('y', (d, i) => @y(i * @barWidth) - @barWidth)
          .attr('width', (d) => @x(d.value))
          .attr('height', () => @barWidth)

    @bars.exit().remove()

    @zeroPad = @g.selectAll('.zero-pad').data(filtered)
    @zeroPad.enter().append('rect')
    @zeroPad.attr('class', (d) ->
      ['zero-pad', 'bar', d.key].join ' ' )

    switch @orientation
      when 'bottom', 'top'
        @zeroPad
          .attr('y', (d) => @y(d.value))
          .attr('x', (d, i) => @x(i * @barWidth) - @barWidth)
          .attr('height', (d) => @x(0) - @x(d.value))
          .attr('width', @barWidth)
      when 'left'
        @zeroPad
          .attr('x', (d) => 0)
          .attr('y', (d, i) => @y(i * @barWidth) - @barWidth)
          .attr('width', (d) => @zeroPadding)
          .attr('height', () => @barWidth)

    @zeroPad.exit().remove()
    @

