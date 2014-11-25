# Used to show a pie graph of a single percent
class Visio.Figures.Circle extends Visio.Figures.Base

  type: Visio.FigureTypes.CIRCLE

  attrAccessible: ['percent', 'number', 'width', 'height']

  initialize: (config) ->

    super config

    @twoPi = 2 * Math.PI

    @arc = d3.svg.arc()
      .startAngle(0)
      .innerRadius(0)
      .outerRadius(@adjustedHeight / 2)

    @centerG = @g.append('g')
      .attr("transform", "translate(" + @adjustedWidth / 2 +
                                  "," + @adjustedHeight / 2 + ")")

    @meter = @centerG.append("g")
      .attr("class", "progress-meter")

    @meter.append("path")
      .attr("class", "background")
      .attr("d", @arc.endAngle(@twoPi))

    @foreground = @meter.append("path")
      .attr("class", "foreground")

    @oldPercent = config.percent || 1

    @oldNumber = config.number || 0

  render: ->
    i = d3.interpolate(@oldPercent, @percent)
    @centerG.transition()
      .duration(Visio.Durations.MEDIUM)
      .tween("percent", () =>
        return (t) =>
          @percent = i(t)
          if _.isNumber @percent
            d = @arc.endAngle @twoPi * @percent
          else
            d = "M0 0Z"


          @foreground.attr('d', d))

    @oldPercent = @percent || 0
    @oldNumber = @number || 0
    @
