class Visio.Figures.Bar extends Visio.Figures.Base

  initialize: (config) ->
    @orientation = config.orientation or 'left'

    # Have to be able to fit labels
    config.margin.right = 40 if config.hasLabels and config.margin.right < 40 and @orientation is 'left'

    super config

    # variable is the scale that will scale the bars to different heights
    @variable = d3.scale.linear()
    @formatter or = Visio.Formats.PERCENT

    # fixed is the scale that scales the bars equally apart
    @fixed = d3.scale.linear()
    @zeroPadding = 3

    switch @orientation
      when 'left'

        @variable.range [0, @adjustedWidth - @zeroPadding - 1]
        @fixed
          .domain([0, @adjustedHeight])
          .range([@adjustedHeight, 0])
      when 'bottom'
        @variable.range [@adjustedHeight - @zeroPadding - 1, 0]
        @fixed
          .domain([0, @adjustedWidth])
          .range([0, @adjustedWidth])




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
    @bars.on 'mouseenter', (d) =>
      console.log d
      console.log @model.toJSON()

    switch @orientation
      when 'bottom'
        @bars.transition().duration(Visio.Durations.FAST)
          .attr('height', (d) => @variable(0) - @variable(d.value))
          .attr('x', (d, i) => @fixed(i * @barWidth))
          .attr('y', (d) => @variable(d.value))
          .attr('width', @barWidth)
      when 'left'
        @bars.transition().duration(Visio.Durations.FAST)
          .attr('x', (d) => @variable(0) + @zeroPadding + 1)
          .attr('y', (d, i) => @fixed(i * @barWidth) - @barWidth)
          .attr('width', (d) => @variable(d.value))
          .attr('height', () => @barWidth)

    @bars.exit().remove()

    @zeroPad = @g.selectAll('.zero-pad').data(filtered)
    @zeroPad.enter().append('rect')
    @zeroPad.attr('class', (d) ->
      ['zero-pad', 'bar', d.key].join ' ' )

    switch @orientation
      when 'bottom'
        @zeroPad
          .attr('height', (d) => @zeroPadding - 1)
          .attr('x', (d, i) => @fixed(i * @barWidth))
          .attr('y', (d) => @adjustedHeight - @zeroPadding)
          .attr('width', @barWidth)
          .attr('text-anchor', 'middle')
      when 'left'
        @zeroPad
          .attr('x', (d) => 0)
          .attr('y', (d, i) => @fixed(i * @barWidth) - @barWidth)
          .attr('width', (d) => @zeroPadding)
          .attr('height', () => @barWidth)

    @zeroPad.exit().remove()

    if @hasLabels
      @labels = @g.selectAll('.label').data filtered
      @labels.enter().append('text')
      @labels.attr('class', (d) ->
        ['label', d.key].join ' ')
        .text (d) =>
          @formatter(d.value)

      switch @orientation
        when 'left'
          @labels
            .attr('x', (d) => @variable(d.value) + 11)
            .attr('y', (d, i) => @fixed(i * @barWidth) - @barWidth)
            .attr('dy', '1em')
        when 'bottom'
          @labels
            .attr('x', (d, i) => @fixed(i * @barWidth))
            .attr('y', (d) => @variable(d.value))
            .attr('dy', '-.3em')
            .attr('width', @barWidth)

    @
