Visio.Figures.isy = (config) ->

  # Variable Declaration
  margin = config.margin

  figureId = config.figureId

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = if config.selection? then config.selection else d3.select($('<div></div>')[0])

  duration = 500

  tooltip = null

  isPerformance = if config.isPerformance? then config.isPerformance else true

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)
    .attr('class', 'isy-figure')

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

  barWidth = 10
  barMargin = 8

  x = d3.scale.linear()
    .domain([0, width / ((2 * barWidth) + barMargin)])
    .range([0, width])

  y = d3.scale.linear()
    .range([height, 0])
    .clamp(true)

  progress =
    start: Visio.Algorithms.REPORTED_VALUES.baseline
    end: Visio.Algorithms.REPORTED_VALUES.myr

  goalType = config.goalType || Visio.Algorithms.GOAL_TYPES.target

  data = config.data || []

  # Rendering
  render = () ->

    filtered = _.filter data, render.filterFn
    console.log filtered
    console.log selection.node()

    boxes = g.selectAll('g.box').data filtered, (d) ->
      d.id
    boxes.enter().append('g')
    console.log g.node()
    boxes.attr('class', (d) -> ['box', "box-#{d.id}"].join(' '))
      .sort(sortFn)
      .transition()
      .duration(duration)
      .attr('transform', (d, i) ->
        'translate(' + x(i) + ', 0)'
      )
      .each((d, i) ->
        box = d3.select @
        baseline = d.get(Visio.Algorithms.REPORTED_VALUES.baseline)

        metrics = [Visio.Algorithms.REPORTED_VALUES.myr, Visio.Algorithms.REPORTED_VALUES.yer]

        y.domain [0, +d.get(goalType)]

        container = box.selectAll('.bar-container').data([d])
        container.enter().append('rect')
        container.attr('width', barWidth * 2)
          .attr('height', height + barMargin)
          .attr('x', 0)
          .attr('y', -barMargin / 2)
          .attr('class', () ->
            classList = ['bar-container']
            classList.push 'inconsistent' unless d.isConsistent()
            return classList.join ' ')

        container.on 'mouseover', (d) ->
          g.selectAll('.box').classed 'faded', true
          box.classed 'faded', false

          tooltip = new Visio.Views.IsyTooltip
            figure: render
            '$figureEl': $(box[0][0])
            isyIndex: i
            model: d

          y.domain [0, +d.get(goalType)]
          circles = box.selectAll('.circle').data(_.values(Visio.Algorithms.REPORTED_VALUES))
          circles.enter().append('circle')
          circles.attr('r', 0)
            .attr('cx', barWidth)
            .attr('cy', (reportedValue) -> y(d.get(reportedValue)))
            .attr('class', 'circle')
          circles.transition()
            .duration(Visio.Durations.VERY_FAST)
            .attr('r', barWidth / 2)

          # can't be in box svg since it need to be top level element
          labels = g.selectAll('.label')
            .data(_.values(Visio.Algorithms.REPORTED_VALUES).concat(Visio.Algorithms.GOAL_TYPES.target))
          labels.enter().append('g')

          labels
            .attr('class', 'label')
            .attr('transform', (type) ->
              i = $(g.selectAll('.box')[0]).index(box[0][0])
              "translate(#{x(i) + barWidth * 3}, #{y(d.get(type))})"
            ).each (p) ->
              label = d3.select @

              tag = label.selectAll('.tag').data([p])
              tag.enter().append('rect')
              tag.attr('x', 0)
                .attr('y', -10)
                .attr('width', 100)
                .attr('height', 20)
                .attr('rx', 5)
                .attr('ry', 5)
                .attr('class', (type) -> ['tag', "tag-#{type}"].join(' '))

              texts = label.selectAll('.text').data([p])
              texts.enter().append('text')
              texts.attr('x', 10)
                .attr('y', 10)
                .attr('dy', '-.43em')
                .attr('class', 'text')
                .text () ->
                  humanGoal = Visio.Utils.humanMetric(goalType)
                  if p != goalType
                    percent = d.get(p) / +d.get(goalType)
                    humanMetric = Visio.Utils.humanMetric(p)
                    return "#{Visio.Formats.PERCENT(percent)} #{humanMetric}"
                  else
                    return "#{humanGoal} is #{d.get(goalType)}"


        container.on 'mouseout', (d) ->
          tooltip.close() if tooltip
          g.selectAll('.box').classed 'faded', false
          box.selectAll('.circle').data([])
            .exit().transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
          g.selectAll('.label').remove()

        container.exit().remove()

        _.each metrics, (metric, idx) ->
          value = d.get(metric)


          reversed = baseline > value
          barHeight = Math.abs(baseline - value)
          bars = box.selectAll(".#{metric}-bar").data([d])
          bars.enter().append('rect')
          bars.attr('class', (d) ->
            classList = ["#{metric}-bar", 'bar']
            classList.push 'reversed' if reversed
            classList.join ' '
          ).attr('x', idx * barWidth)

          bars.transition()
            .duration(duration)
            .attr('y', (d) ->
              if reversed
                return y(value + barHeight)
              else
                return y(baseline + barHeight)
            ).attr('width', barWidth)
            .attr('height', (d) ->
              return y(0) - y(barHeight))
          bars.exit().remove()

        max = d3.max metrics, (metric) ->
          +d.get(metric)

        reversed = baseline > max

        box.classed 'reversed', reversed

        center = box.selectAll('.center').data([d])
        center.enter().append('line')
        center.attr('class', 'center')
        center.transition()
          .duration(duration)
          .attr('x1', barWidth)
          .attr('y1', (d) -> if reversed then y(baseline) else y(max))
          .attr('x2', barWidth)
          .attr('y2', (d) -> y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
        center.exit().remove()

        whisker = box.selectAll('.whisker').data([d])
        whisker.enter().append('line')
        whisker.attr('class', 'whisker')
        whisker.transition()
          .duration(duration)
          .attr('x1', barWidth / 2 + 2)
          .attr('y1', (d) -> y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
          .attr('x2', 1.5 * barWidth - 2)
          .attr('y2', (d) -> y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
        whisker.exit().remove()

      )
    boxes.on 'click', (d) ->
      $.publish "select.#{figureId}", [d]

    console.log g.node()
    boxes.exit().remove()

  render.data = (_data) ->
    return data unless arguments.length
    data = _data
    render

  render.isPerformance = (_isPerformance) ->
    return isPerformance unless arguments.length
    isPerformance = _isPerformance
    goal = Visio.Algorithms.GOAL_TYPES.target if isPerformance
    render

  render.goalType = (_goalType) ->
    return goalType unless arguments.length
    goalType = _goalType
    render

  render.x = (_x) ->
    return x unless arguments.length
    x = _x
    render

  render.width = (_width) ->
    return width unless arguments.length
    width = _width
    render

  render.unsubscribe = ->
    $.unsubscribe "select.#{figureId}.figure"

  render.config = ->
    return {
      margin: margin
      width: config.width
      height: config.height
      goalType: goalType
      isPerformance: isPerformance
      data: data
    }

  render.exportId = ->
    return figureId + '_export'

  render.filterFn = (d) ->
    d.get('is_performance') == isPerformance

  render.el = () ->
    return selection.node()

  render.exportId = ->
    return figureId + '_export'

  select = (e, d) ->
    box = g.select(".box-#{d.id}")
    isActive = box.classed 'active'
    box.classed 'active', not isActive

  sortFn = (a, b) ->
    reversedA = if a.get(progress.start) > a.get(progress.end) then -1 else 1
    reversedB = if b.get(progress.start) > b.get(progress.end) then -1 else 1
    (reversedA * scaledBarHeight(a)) - (reversedB * scaledBarHeight(b))

  scaledBarHeight = (d) ->
    y.domain [0, +d.get(goalType)]
    v = Math.abs(+d.get(progress.start) - +d.get(progress.end))
    y(v)

  $.subscribe "select.#{figureId}.figure", select
  render

