class Visio.Figures.Bar extends Visio.Figures.Base

  initialize: (config) ->
    @orientation = config.orientation or 'left'

    # Have to be able to fit labels
    config.margin.right = 40 if config.hasLabels and config.margin.right < 40 and @orientation is 'left'

    super config

    # variable is the scale that will scale the bars to different heights
    @variable = d3.scale.linear()

    if @orientation == 'bottom'
      @formatter or= Visio.Formats.PERCENT_NOSIGN
    else
      @formatter or= Visio.Formats.PERCENT

    # fixed is the scale that scales the bars equally apart
    @fixed = d3.scale.ordinal()
    @zeroPadding = 3
    @labelHeight = 18

    switch @orientation
      when 'left'

        @variable.range [0, @adjustedWidth - @zeroPadding - 1]
        @fixed
          .rangeBands([@adjustedHeight, 0])
      when 'bottom'
        @variable.range [@adjustedHeight - @zeroPadding - 1, 0]
        @fixed
          .rangeBands([0, @adjustedWidth])




  render: ->

    # Choose collection over model
    filtered = @filtered(@collection || @model)

    @fixed.domain _.times(filtered.length, (n) -> n)

    @barWidth = switch @orientation
      when 'top', 'bottom' then @adjustedWidth / filtered.length
      when 'right', 'left'
        if @hasLabels
          (@adjustedHeight - (@labelHeight * filtered.length)) / filtered.length
        else
          @adjustedHeight / filtered.length

    @barWidth = 0 if _.isNaN @barWidth


    @bars = @g.selectAll('.bar').data(filtered)
    @bars.enter().append('rect')
    @bars.attr('class', (d) ->
      ['bar', d.key].join ' ' )

    switch @orientation
      when 'bottom'
        @bars.transition().duration(Visio.Durations.FAST)
          .attr('height', (d) => @variable(0) - @variable(d.value))
          .attr('x', (d, i) => @fixed(i))
          .attr('y', (d) => @variable(d.value))
          .attr('width', @barWidth)
      when 'left'
        @bars.transition().duration(Visio.Durations.FAST)
          .attr('x', (d) => @variable(0) + @zeroPadding + 1)
          .attr('y', (d, i) =>
            y = @fixed(i)
            y += @labelHeight if @hasLabels
            y)
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
          .attr('x', (d, i) => @fixed(i))
          .attr('y', (d) => @adjustedHeight - @zeroPadding)
          .attr('width', @barWidth)
          .attr('text-anchor', 'middle')
      when 'left'
        @zeroPad
          .attr('x', (d) => 0)
          .attr('y', (d, i) =>
            y = @fixed(i)
            y += @labelHeight if @hasLabels
            y)
          .attr('width', (d) => @zeroPadding)
          .attr('height', () => @barWidth)

    @zeroPad.exit().remove()

    if @hasLabels
      @labels = @g.selectAll('.label').data filtered
      @labels.enter().append('text')
      @labels.attr('class', (d) ->
        ['label', d.key].join ' ')

      switch @orientation
        when 'left'
          @labels
            .attr('x', (d) => )
            .attr('y', (d, i) =>
              y = @fixed(i) - @labelHeight
              y += @labelHeight if @hasLabels
              y)
            .attr('dy', '1em')
            .text((d) =>
                Visio.Utils.humanMetric(d.key).toUpperCase() + ' ')
              .append('tspan')
              .text((d) => @formatter(d.value))
        when 'bottom'
          @labels
            .attr('x', (d, i) => @fixed(i) + @barWidth / 2)
            .attr('y', (d) => @variable(d.value))
            .attr('dy', '-.3em')
            .attr('width', @barWidth)
            .attr('text-anchor', 'middle')
            .text (d) =>
              @formatter(d.value)

    @
