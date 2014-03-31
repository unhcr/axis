class Visio.Figures.Isy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ISY

  attrAccessible: ['x', 'y', 'width', 'height', 'collection', 'margin', 'goalType', 'isPerformance']

  initialize: (config) ->

    @filters = new Visio.Collections.FigureFilter([
      {
        id: 'is_performance'
        filterType: 'radio'
        values: { true: true, false: false }
        human: { true: 'performance', false: 'impact' }
        callback: (name, attr) =>
          @isPerformanceFn(name == 'true').render()
          $.publish "drawFigures.#{@cid}.figure"
      },
      {
        id: 'achievement'
        filterType: 'radio'
        values: _.object(_.values(Visio.Algorithms.GOAL_TYPES), _.values(Visio.Algorithms.GOAL_TYPES).map(
          (achievement_type) ->
            Visio.manager.get('achievement_type') == achievement_type))
        callback: (name, attr) =>
          @goalTypeFn(name).render()
      }
    ])

    super config

    @tooltip = null

    @isPerformance = if config.isPerformance? then config.isPerformance else true

    @tipHeight = 8
    @barWidth = 10
    @barMargin = 8
    @maxIndicators = Math.floor @adjustedWidth / (2 * @barWidth + @barMargin)

    @x = d3.scale.linear()
      .domain([0, @maxIndicators])
      .range([0, @adjustedWidth])

    @y = d3.scale.linear()
      .range([@adjustedHeight, 0])

    @scale = d3.scale.linear()
      .range([0, @adjustedHeight])
      .domain([1, 0])

    @yAxis = d3.svg.axis()
      .scale(@scale)
      .orient('left')
      .ticks(5)
      .tickFormat(Visio.Formats.PERCENT)
      .tickSize(-@adjustedWidth)

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')

    @goalType = config.goalType || Visio.Algorithms.GOAL_TYPES.target

    @$el.on 'mouseleave', (e) =>
      @tooltip?.close()

    $.subscribe "hover.#{@cid}.figure", @hover
    $.subscribe "mouseout.#{@cid}.figure", @mouseout

    @sortAttribute = Visio.ProgressTypes.BASELINE_MYR

  render: ->
    filtered = @filtered @collection

    self = @

    boxes = @g.selectAll('g.box').data filtered, (d) -> d.id
    boxes.enter().append('g')
    boxes.attr('class', (d) -> ['box', "box-#{d.id}"].join(' '))
      .style('opacity', (d, i) -> if self.x(i) < 0 then 0 else 1)
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('transform', (d, i) -> 'translate(' + self.x(i) + ', 0)')
      .each((d, i) ->
        box = d3.select @
        baseline = d.get(Visio.Algorithms.REPORTED_VALUES.baseline)

        metrics = [Visio.Algorithms.REPORTED_VALUES.myr, Visio.Algorithms.REPORTED_VALUES.yer]

        self.y.domain [0, +d.get(self.goalType)]

        container = box.selectAll('.bar-container').data([d])
        container.enter().append('rect')
        container.attr('width', self.barWidth * 2)
          .attr('height', self.height + self.barMargin)
          .attr('x', 0)
          .attr('y', -self.barMargin / 2)
          .attr('class', () ->
            classList = ['bar-container']
            classList.push 'inconsistent' unless d.isConsistent()
            return classList.join ' ')

        container.on 'mouseenter', (d) ->
          $.publish "hover.#{self.cid}.figure", i

        container.on 'mouseout', (d) ->
          $.publish "mouseout.#{self.cid}.figure", i

        container.exit().remove()

        _.each metrics, (metric, idx) ->
          value = if d.get(metric) > d.get(self.goalType) then d.get(self.goalType) else d.get(metric)


          reversed = baseline > value

          barHeight = Math.abs(baseline - value)
          bars = box.selectAll(".#{metric}-bar").data([d])

          bars.enter().append('polygon')
          bars.attr('class', (d) ->
            classList = ["#{metric}-bar", 'bar']
            classList.push 'reversed' if reversed
            classList.join ' '
          )
          bars.transition()
            .duration(Visio.Durations.FAST)
            .attr('points', (d) ->
              points = []

              y = if reversed
                self.y(value + barHeight)
              else
                self.y(baseline + barHeight)

              height = self.y(0) - self.y(barHeight)
              # BaseLeft
              points.push [idx * self.barWidth, y]

              # BaseRight
              points.push [(idx + 1) * self.barWidth, y]

              # VariableRight
              points.push [(idx + 1) * self.barWidth, y + height]

              # VariableLeft
              points.push [idx * self.barWidth, y + height]

              if metric == Visio.Algorithms.REPORTED_VALUES.yer and reversed
                points[2][1] -= self.tipHeight
              else if metric == Visio.Algorithms.REPORTED_VALUES.yer and not reversed
                points[0][1] -= self.tipHeight
              else if metric == Visio.Algorithms.REPORTED_VALUES.myr and reversed
                points[3][1] -= self.tipHeight
              else if metric == Visio.Algorithms.REPORTED_VALUES.myr and not reversed
                points[1][1] -= self.tipHeight

              path = _.map(points, (point) -> point.join(',')).join(' ')

              path)

          bars.exit().remove()

        center = box.selectAll('.center').data([d])
        center.enter().append('line')
        center.attr('class', 'center')
        center.transition()
          .duration(Visio.Durations.FAST)
          .attr('x1', self.barWidth)
          .attr('y1', (d) -> self.y baseline )
          .attr('x2', self.barWidth)
          .attr('y2', (d) -> self.y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
        center.exit().remove()

        target = box.selectAll('.target').data([d])
        target.enter().append('g')
        target.attr('class', 'target')
        target.transition()
          .duration(Visio.Durations.FAST)
          .attr('transform', (d) ->
            'translate(0, ' + self.y(d.get(Visio.Algorithms.GOAL_TYPES.target)) + ')')
          .each((d) -> self.circleLabel(d, @, 'T'))

        target.enter().append('circle')
        target.exit().remove()

        baseline = box.selectAll('.baseline').data([d])
        baseline.enter().append('g')
        baseline.attr('class', 'baseline')
        baseline.transition()
          .duration(Visio.Durations.FAST)
          .attr('transform', (d) ->
            'translate(0, ' + self.y(d.get(Visio.Algorithms.REPORTED_VALUES.baseline)) + ')')
          .each((d) -> self.circleLabel(d, @, 'B'))

        baseline.enter().append('circle')
        baseline.exit().remove()
      )

    boxes.on 'click', (d, i) =>
      $.publish "select.#{@figureId()}", [d, i]

    boxes.exit().remove()
    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)
    @

  circleLabel: (d, svgEl, letter) ->
    g = d3.select svgEl
    circle = g.selectAll('circle').data([d])
    circle.enter().append('circle')
    circle.attr('cx', @barWidth)
      .attr('r', 8)
    text = g.selectAll('text').data([d])
    text.enter().append('text')
    text.attr('x', @barWidth)
      .attr('text-anchor', 'middle')
      .attr('dy', '.4em')
      .text(letter)

  sortFn: (a, b) =>

    reversedA = if a.get('reversal') then -1 else 1
    reversedB = if b.get('reversal') then -1 else 1

    (reversedB * @progressDifference(b)) - (reversedA * @progressDifference(a))

  filterFn: (d) => d.get('is_performance') == @isPerformance

  progressDifference: (d) =>
    scale = d3.scale.linear()
      .domain([0, +d.get(@goalType)])
      .range([0, 1])


    end = +d.get(@sortAttribute.end)
    start = +d.get(@sortAttribute.start)

    delta = start - end
    -scale delta

  filtered: (collection) => _.chain(collection.models).filter(@filterFn).sort(@sortFn).value()

  select: (e, d, i) =>
    box = @g.select(".box-#{d.id}")
    isActive = box.classed 'active'
    box.classed 'active', not isActive

  hover: (e, idx) =>
    datum = null
    box = null

    boxes = @g.selectAll('.box')
    boxes.sort(@sortFn).each (d, i) ->
      el = d3.select(@)
      el.classed 'faded', true
      if idx == i
        el.classed 'faded', false
        datum = d
        box = el

    if idx >= @maxIndicators
      difference = idx - @maxIndicators
      @x.domain [0 + difference, @maxIndicators + difference]
      @render()
    else if @x.domain()[0] >= 0
      @x.domain [0, @maxIndicators]
      @render()

    self = @

    @g.selectAll('.circle').data([])
      .exit().transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    @g.selectAll('.label').remove()

    @tooltip or= new Visio.Views.IsyTooltip
    @tooltip.figure = self
    @tooltip.isyIndex = i
    @tooltip.model = datum
    @tooltip.render()

    @y.domain [0, +datum.get(@goalType)]

    labelData = [Visio.Algorithms.REPORTED_VALUES.yer, Visio.Algorithms.REPORTED_VALUES.myr]

    circles = box.selectAll('.circle').data(labelData)
    circles.enter().append('circle')
    circles.attr('r', 0)
      .attr('cx', @barWidth)
      .attr('cy', (reportedValue) => @y(datum.get(reportedValue)))
      .attr('class', 'circle')
    circles.transition()
      .duration(Visio.Durations.VERY_FAST)
      .attr('r', @barWidth / 2)

    # can't be in box svg since it need to be top level element
    labels = @g.selectAll('.label')
      .data(_.values(Visio.Algorithms.REPORTED_VALUES).concat(Visio.Algorithms.GOAL_TYPES.target))
    labels.enter().append('g')

    labels
      .attr('class', 'label')
      .attr('transform', (type) =>
        "translate(#{@x(idx) + @barWidth * 3}, #{@y(datum.get(type))})"
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
            humanGoal = Visio.Utils.humanMetric(self.goalType)
            if p != self.goalType
              percent = datum.get(p) / +datum.get(self.goalType)
              humanMetric = Visio.Utils.humanMetric(p)
              return "#{Visio.Formats.PERCENT(percent)} #{humanMetric}"
            else
              return "#{humanGoal} is #{datum.get(self.goalType)}"

  mouseout: =>
    @g.selectAll('.box').classed 'faded', false
    @g.selectAll('.circle').data([])
      .exit().transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    @g.selectAll('.label').remove()

  close: ->
    @unbind()
    $.unsubscribe "hover.#{@cid}.figure"
    $.unsubscribe "mouseout.#{@cid}.figure"
    @tooltip?.close()
    @remove()
