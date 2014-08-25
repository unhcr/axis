class Visio.Figures.Isy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ISY

  attrAccessible: ['x', 'y', 'width', 'height', 'collection', 'margin', 'goalType', 'isPerformance']

  initialize: (config) ->
    config.query or= ''

    humanGoalTypes = _.object _.values(Visio.Algorithms.GOAL_TYPES),
                              _.values(Visio.Algorithms.GOAL_TYPES).map((goalType) ->
                                Visio.Utils.humanMetric(goalType))
    performanceValues =
      true: false
      false: true
    # For indicator dashboard just set the proper indicator type
    if Visio.manager.get('indicator')?
      performanceValues =
        true: Visio.manager.get('indicator').get('is_performance')
        false: !Visio.manager.get('indicator').get('is_performance')

    @filters = new Visio.Collections.FigureFilter([
      {
        id: 'is_performance'
        filterType: 'radio'
        values: performanceValues
        human: { true: 'performance', false: 'impact' }
        hidden: Visio.manager.get('indicator')?
        callback: (name, attr) =>
          @selectedDatum = null
          @isPerformanceFn(name == 'true')
          @x.domain [0, @maxIndicators]
          $.publish "drawFigures.#{@cid}.figure"
          $.publish "hover.#{@cid}.figure", 0
      },
      {
        id: 'achievement'
        filterType: 'radio'
        values: _.object(_.values(Visio.Algorithms.GOAL_TYPES), _.values(Visio.Algorithms.GOAL_TYPES).map(
          (achievement_type) ->
            Visio.manager.get('achievement_type') == achievement_type))
        human: humanGoalTypes
        callback: (name, attr) =>
          @goalTypeFn(name).render()
          $.publish "hover.#{@cid}.figure", @selectedDatum || 0
      }
    ])

    super config

    @tooltip = new Visio.Views.IsyTooltip
      figure: @

    @$el.find('.tooltip-container').html @tooltip.el

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

    @goalType = config.goalType || Visio.Algorithms.GOAL_TYPES.target

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")
        .attr("y", -10)
        .attr("x", @adjustedWidth)
        .attr("dy", "-.21em")
        .attr('text-anchor', 'end')
        .text(Visio.Utils.humanMetric(@goalType))


    $.subscribe "hover.#{@cid}.figure", @hover
    $.subscribe "mouseout.#{@cid}.figure", @mouseout

    @sortAttribute = Visio.ProgressTypes.BASELINE_MYR
    @isPerformanceFn @filters.get('is_performance').active() == 'true'

    $(@svg.node()).parent().on 'mouseleave', =>
      $.publish "hover.#{@cid}.figure", [@selectedDatum, true] if @selectedDatum

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
          .attr('class', (d) ->
            classList = ['bar-container']
            classList.push 'inconsistent' unless d.consistent().isConsistent
            classList.push 'selected' if d.id == self.selectedDatum?.id
            classList.push 'hover' if d.id == self.hoverDatum?.id

            return classList.join ' ')
          .style('stroke-dasharray', (d) ->
            topDash = self.barWidth * 2
            perimeter = (self.barWidth * 4) + ((self.height + self.barMargin) * 2)

            [topDash, perimeter - topDash].join ' ' )
          .style('fill', (d) -> 'url(#stripes-alert)' unless d.consistent().isConsistent)

        container.on 'mouseenter', (d) ->
          $.publish "hover.#{self.cid}.figure", [i, false]

        container.on 'mouseout', (d) ->
          $.publish "mouseout.#{self.cid}.figure", i

        container.exit().remove()

        footer = box.selectAll('.bar-footer').data([d])
        footer.enter().append('rect')
        footer.attr('width', self.barWidth * 2)
          .attr('height', self.barMargin)
          .attr('x', 0)
          .attr('y', self.adjustedHeight + self.barMargin + 2)
          .attr('class', (d) ->
            classList = ['bar-footer']
            unless d.get('is_performance')
              category = d.situationAnalysis().category
              classList.push category if category
            return classList.join ' ')

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

        if d.get(Visio.Algorithms.GOAL_TYPES.target)?
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

        if d.get(Visio.Algorithms.REPORTED_VALUES.baseline)?
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
      if @selectedDatum?.id == d.id
        barContainer = @g.select ".box-#{d.id} .bar-container"
        barContainer.classed 'selected', false
        @selectedDatum = null
        return

      @selectedDatum = d
      @g.selectAll('.bar-container').classed 'selected', false
      barContainer = @g.select ".box-#{d.id} .bar-container"
      barContainer.classed 'selected', true
      $.publish "select.#{@figureId()}", [d, i]

    boxes.exit().remove()
    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)
        .select('text')
        .text(Visio.Utils.humanMetric(@goalType))
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

  transformSortFn: (a, b) =>
    elA = @g.select ".box-#{a.id}"
    elB = @g.select ".box-#{b.id}"
    transformA = Visio.Utils.parseTransform elA.attr('transform')
    transformB = Visio.Utils.parseTransform elB.attr('transform')

    transformA.translate[0] - transformB.translate[0]

  filterFn: (d) => d.get('is_performance') == @isPerformance

  progressDifference: (d) =>
    scale = d3.scale.linear()
      .domain([0, +d.get(@goalType)])
      .range([0, 1])


    end = +d.get(@sortAttribute.end)
    start = +d.get(@sortAttribute.start)

    delta = start - end
    -scale delta

  queryByFn: (d) =>
    _.isEmpty(@query) or d.indicator().toString().toLowerCase().indexOf(@query.toLowerCase()) != -1

  filtered: (collection) =>
    _.chain(collection.models).filter(@filterFn).filter(@queryByFn).sort(@sortFn).value()

  findBoxByIndex: (idx) =>
    boxes = @g.selectAll('.box')
    result = { box: null, idx: idx, datum: null }
    boxes.sort(@transformSortFn).each (d, i) ->
      if idx == i
        result.box = d3.select(@)
        result.datum = d

    result


  findBoxByDatum: (datum) =>
    boxes = @g.selectAll('.box')
    result = { box: null, idx: null, datum: datum }
    boxes.sort(@transformSortFn).each (d, i) ->
      if d.id == datum.id
        result.box = d3.select(@)
        result.idx = i

    result

  select: (e, d, i) =>
    box = @g.select(".box-#{d.id}")
    isActive = box.classed 'active'
    box.classed 'active', not isActive

  hover: (e, idxOrDatum, scroll = true) =>
    self = @
    @hoverDatum = null
    box = null
    idx = null

    boxes = @g.selectAll('.box')
    boxes.selectAll('.bar-container').classed 'hover', false

    if idxOrDatum instanceof Visio.Models.IndicatorDatum
      @hoverDatum = idxOrDatum
      result = @findBoxByDatum @hoverDatum
    else
      idx = idxOrDatum
      result = @findBoxByIndex idx

    box = result.box
    idx = result.idx
    @hoverDatum = result.datum

    return unless @hoverDatum?
    box.select('.bar-container').classed 'hover', true

    if idx >= @maxIndicators and scroll
      difference = idx - @maxIndicators
      @x.domain [0 + difference, @maxIndicators + difference]
      @g.selectAll('g.box').attr('transform', (d, i) => 'translate(' + @x(i) + ', 0)')
        .style('opacity', (d, i) -> if self.x(i) < 0 then 0 else 1)
    else if @x.domain()[0] > 0 and scroll
      @x.domain [0, @maxIndicators]
      @g.selectAll('g.box').attr('transform', (d, i) => 'translate(' + @x(i) + ', 0)')
        .style('opacity', (d, i) -> if self.x(i) < 0 then 0 else 1)

    @g.selectAll('.circle').data([])
      .exit().transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    @g.selectAll('.label').remove()

    @tooltip.render @hoverDatum

    @y.domain [0, +@hoverDatum.get(@goalType)]

    circleData = [Visio.Algorithms.REPORTED_VALUES.yer, Visio.Algorithms.REPORTED_VALUES.myr]

    circles = box.selectAll('.circle').data(circleData)
    circles.enter().append('circle')
    circles.attr('r', 0)
      .attr('cx', @barWidth)
      .attr('cy', (reportedValue) => @y(@hoverDatum.get(reportedValue)))
      .attr('class', 'circle')
    circles.transition()
      .duration(Visio.Durations.VERY_FAST)
      .attr('r', @barWidth / 2)

    labelData = _.values(Visio.Algorithms.REPORTED_VALUES).concat(Visio.Algorithms.GOAL_TYPES.target)
    labelHeight = 20
    labelPositions = @computeLabelPositions labelData, self.hoverDatum, labelHeight


    labels = box.selectAll('.label')
      .data(labelData)
    labels.enter().append('g')
    labels
      .attr('class', 'label')
      .each (p) ->
        label = d3.select @
        offset = 10

        tag = label.selectAll('.tag').data([p])
        tag.enter().append('rect')
        tag.attr('x', self.barWidth * 3)
          .attr('y', (reportedValue) =>
            labelPositions[reportedValue] - offset)
          .attr('width', 100)
          .attr('height', labelHeight)
          .attr('rx', 3)
          .attr('ry', 3)
          .attr('class', (type) -> ['tag', "tag-#{type}"].join(' '))

        texts = label.selectAll('.text').data([p])
        texts.enter().append('text')
        texts.attr('x', self.barWidth * 4)
          .attr('y', (reportedValue) =>
            labelPositions[reportedValue] + offset)
          .attr('dy', '-.43em')
          .attr('class', 'text')
          .text () ->
            humanGoal = Visio.Utils.humanMetric(self.goalType)
            if p != self.goalType
              percent = self.hoverDatum.get(p) / +self.hoverDatum.get(self.goalType)
              humanMetric = Visio.Utils.humanMetric(p)
              return "#{Visio.Formats.PERCENT(percent)} #{humanMetric}"
            else
              return "#{humanGoal} is #{self.hoverDatum.get(self.goalType)}"

    box.moveToFront()

  computeLabelPositions: (attributes, datum, length) =>
    values = _.map attributes, (attr) =>
      value = @y(+datum.get(attr))
      return {
        value: value
        attr: attr
      }

    values.sort (a, b) -> a.value - b.value

    positions = []
    positionsHash = {}
    nValues = values.length

    _.each values, (value, idx) =>

      last = positions[positions.length - 1]

      if last?
        delta = value.value - last.value
        value.value += (length - delta) if delta < length

      positions.push value
      positionsHash[value.attr] = value.value

    positionsHash

  mouseout: (e, i) =>
    @g.selectAll('.bar-container').classed 'hover', false
    @g.selectAll('.circle').data([])
      .exit().transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    @g.selectAll('.label').remove()

  close: ->
    @unbind()
    $.unsubscribe "hover.#{@cid}.figure"
    $.unsubscribe "mouseout.#{@cid}.figure"
    @tooltip?.close()
    @remove()
