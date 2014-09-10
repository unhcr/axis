class Visio.Figures.Isy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ISY

  templateTooltip: HAML['tooltips/isy']

  attrAccessible: ['x', 'y', 'width', 'height', 'collection', 'margin', 'goalType', 'isPerformance']

  initialize: (config) ->
    config.query or= ''

    humanGoalTypes = _.object _.values(Visio.Algorithms.GOAL_TYPES),
                              _.values(Visio.Algorithms.GOAL_TYPES).map((goalType) ->
                                Visio.Utils.humanMetric(goalType))
    performanceValues =
      true: if config.isPerformance? then config.isPerformance else false
      false: if config.isPerformance? then config.isPerformance else true
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


    @isPerformance = if config.isPerformance? then config.isPerformance else true

    @footerHeight = 22
    @tipHeight = 8
    @barWidth = 8
    @barMargin = 8

    # Label Variables
    @labelContainerWidth = 335
    @labelContainerPaddingLeft = 50


    @graphWidth = @adjustedWidth - @labelContainerWidth - @labelContainerPaddingLeft
    @maxIndicators = Math.floor (@graphWidth) / (2 * @barWidth + @barMargin)

    @x = d3.scale.linear()
      .domain([0, @maxIndicators])
      .range([0, @graphWidth])

    @y = d3.scale.linear()
      .range([@adjustedHeight, 0])
      .clamp(true)

    @scale = d3.scale.linear()
      .range([0, @adjustedHeight])
      .domain([1, 0])

    @tickPadding = 20

    @yAxis = d3.svg.axis()
      .scale(@scale)
      .orient('left')
      .ticks(3)
      .tickFormat((d) -> (if d == 1 then Visio.Formats.PERCENT(d) else d * 100))
      .tickSize(-@adjustedWidth)
      .tickPadding(@tickPadding)

    @goalType = config.goalType || Visio.Algorithms.GOAL_TYPES.target

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', "translate(0,0)")
      .append("text")
        .attr("y", -60)
        .attr("transform", "translate(#{-@tickPadding}, 0)")
        .attr("dy", "-.21em")
        .attr('text-anchor', 'end')
        .html =>
          @yAxisLabel()


    $.subscribe "hover.#{@cid}.figure", @hover
    $.subscribe "mouseout.#{@cid}.figure", @mouseout

    @sortAttribute = Visio.ProgressTypes.BASELINE_MYR
    @isPerformanceFn @filters.get('is_performance').active() == 'true'

    @legendView = new Visio.Legends.Isy()
    @labelView = new Visio.Labels.Isy()

    # Lines
    #
    # Bottom line of ISY graph
    @g.append('line')
      .attr('class', 'isy-line')
      .attr('x1', 0)
      .attr('x2', @adjustedWidth)
      .attr('y1', @adjustedHeight + 2 * @footerHeight)
      .attr('y2', @adjustedHeight + 2 * @footerHeight)

    # Bottom line of criticality dots
    @g.append('line')
      .attr('class', 'isy-line')
      .attr('x1', 0)
      .attr('x2', @adjustedWidth)
      .attr('y1', @adjustedHeight)
      .attr('y2', @adjustedHeight)

    # Divider line between ISY and labels
    @g.append('line')
      .attr('class', 'isy-line isy-label-line')
      .attr('x1', @adjustedWidth - @labelContainerWidth)
      .attr('x2', @adjustedWidth - @labelContainerWidth)
      .attr('y1', @adjustedHeight)
      .attr('y2', 0 - @barMargin)

    # Labels
    @g.append('text')
      .attr('class', 'label')
      .attr('x', @graphWidth + @labelContainerPaddingLeft)
      .attr('text-anchor', 'start')
      .attr('y', @adjustedHeight + @footerHeight)
      .attr('dy', '.33em')
      .text 'Impact Criticality'



    $(@svg.node()).parent().on 'mouseleave', =>
      $.publish "hover.#{@cid}.figure", [@selectedDatum, true] if @selectedDatum

  render: ->
    filtered = @filtered @collection

    self = @

    boxes = @g.selectAll('g.box').data filtered, (d) -> d.id
    boxes.enter().append('g')
    boxes.attr('class', @boxClasslist)
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('transform', (d, i) -> 'translate(' + self.x(i) + ', 0)')
      .attr('original-title', (d) ->
        values = [
          { value: Visio.Algorithms.GOAL_TYPES.target, human: 'Target' },
          { value: Visio.Algorithms.GOAL_TYPES.compTarget, human: 'Comp Target' },
          { value: Visio.Algorithms.GOAL_TYPES.standard, human: 'Standard' }
          { value: Visio.Algorithms.REPORTED_VALUES.yer, human: 'YER' },
          { value: Visio.Algorithms.REPORTED_VALUES.myr, human: 'MYR' },
          { value: Visio.Algorithms.REPORTED_VALUES.baseline, human: 'Baseline' },
        ]
        self.templateTooltip
          d: d
          values: values
      )
      .each((d, i) ->
        box = d3.select @
        baseline = d.get(Visio.Algorithms.REPORTED_VALUES.baseline)

        metrics = [Visio.Algorithms.REPORTED_VALUES.myr, Visio.Algorithms.REPORTED_VALUES.yer]

        self.y.domain [0, +d.get(self.goalType)]

        container = box.selectAll('.bar-container').data([d])
        container.enter().append('rect')
        container.attr('width', self.barWidth * 2)
          .attr('height', self.adjustedHeight + self.barMargin)
          .attr('x', 0)
          .attr('y', -self.barMargin)
          .attr('class', (d) ->
            classList = ['bar-container']
            classList.push 'selected' if d.id == self.selectedDatum?.id
            classList.push 'hover' if d.id == self.hoverDatum?.id

            return classList.join ' ')

        hoverContainer = box.selectAll('.hover-container').data([d])
        hoverContainer.enter().append('rect')
        hoverContainer.attr('width', self.barWidth * 2)
          .attr('height', self.adjustedHeight + self.barMargin + 2 * self.footerHeight)
          .attr('x', 0)
          .attr('y', -self.barMargin)
          .attr('class', (d) ->
            classList = ['hover-container']
            classList.push 'selected' if d.id == self.selectedDatum?.id
            classList.push 'hover' if d.id == self.hoverDatum?.id
            classList.join ' ')

        hoverContainer.exit().remove()


        hoverContainer.on 'mouseenter', (d) ->
          $.publish "hover.#{self.cid}.figure", [i, false]

        hoverContainer.on 'mouseout', (d) ->
          $.publish "mouseout.#{self.cid}.figure", i

        container.exit().remove()

        footer = box.selectAll('.bar-footer').data([d])
        footer.enter().append('circle')
        footer.attr('r', self.barWidth / 2)
          .attr('cx', self.barWidth)
          .attr('cy', self.adjustedHeight + self.footerHeight)
          .attr('class', (d) ->
            classList = ['bar-footer']
            unless d.get('is_performance')
              category = d.situationAnalysis().category
              classList.push category if category
            return classList.join ' ')

        _.each metrics, (metric, idx) ->
          value = if d.get(metric) > d.get(self.goalType) then d.get(self.goalType) else d.get(metric)


          reversed = baseline > value

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
              X = 0
              Y = 1

              # BaseLeft
              points.push [idx * self.barWidth, self.y(baseline)]

              # BaseRight
              points.push [(idx + 1) * self.barWidth, self.y(baseline)]

              # VariableRight
              points.push [(idx + 1) * self.barWidth, self.y(value)]

              # VariableLeft
              points.push [idx * self.barWidth, self.y(value)]

              if metric == Visio.Algorithms.REPORTED_VALUES.yer and reversed
                points[2][Y] -= self.tipHeight
              else if metric == Visio.Algorithms.REPORTED_VALUES.yer and not reversed
                points[3][Y] -= self.tipHeight
              else if metric == Visio.Algorithms.REPORTED_VALUES.myr and reversed
                points[3][Y] -= self.tipHeight
              else if metric == Visio.Algorithms.REPORTED_VALUES.myr and not reversed
                points[2][Y] -= self.tipHeight

              path = _.map(points, (point) -> point.join(',')).join(' ')

              path)

          bars.exit().remove()

        if d.get(Visio.Algorithms.GOAL_TYPES.target)?
          target = box.selectAll('.target').data([d])
          target.enter().append('circle')
          target.attr('class', 'target')
          target.transition()
            .duration(Visio.Durations.FAST)
            .attr('r', 5)
            .attr('cy', (d) ->
              self.y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
            .attr('cx', self.barWidth)

          target.exit().remove()

        if d.get(Visio.Algorithms.REPORTED_VALUES.baseline)?
          baseline = box.selectAll('.baseline').data([d])
          baseline.enter().append('polygon')
          baseline.attr('class', 'baseline')
          baseline.transition()
            .duration(Visio.Durations.FAST)
            .attr('points', (d) ->
              points = []

              y = self.y(d.get(Visio.Algorithms.REPORTED_VALUES.baseline))

              # Left
              points.push [0, y]

              # Bottom
              points.push [self.barWidth, y + self.barWidth]

              # Right
              points.push [2 * self.barWidth, y]

              # Top
              points.push [self.barWidth, y - self.barWidth]

              path = _.map(points, (point) -> point.join(',')).join(' ')

            )

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

    boxes.on 'mouseover', (d, i) =>
      offset = @$el.find('.figure').position()
      $labels = $ '#module .isy-labels'

      $labels.css
        left: offset.left + @graphWidth + @margin.left + 50
        top: offset.top + 70
      $labels.html @labelView.render(d).el


    boxes.exit().remove()


    # Parameter Labels


    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)

    @g.select('.y.axis text')
      .html =>
        @yAxisLabel()

    @$el.find('.legend-container').html @legendView.render().el unless @isExport
    @$el.find('.box').tipsy
      trigger: 'hover'
    @

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


    if scroll
      if idx >= @maxIndicators
        difference = idx - @maxIndicators
        @x.domain [0 + difference, @maxIndicators + difference]
      else if @x.domain()[0] > 0
        @x.domain [0, @maxIndicators]

      @g.selectAll('g.box').attr('transform', (d, i) => 'translate(' + @x(i) + ', 0)')
        .attr 'class', @boxClasslist

    @y.domain [0, +@hoverDatum.get(@goalType)]

  boxClasslist: (d, i) =>
    classList = ['box', "box-#{d.id}"]
    classList.push 'box-invisible'  if @x(i) < @x.range()[0] or @x(i) > @x.range()[1]
    classList.push 'gone'  if @x(i) < @x.range()[0] or @x(i) > @x.range()[1]
    classList.push 'inconsistent' unless d.consistent().isConsistent
    classList.join(' ')


  mouseout: (e, i) =>
    @g.selectAll('.bar-container').classed 'hover', false

  close: ->
    @unbind()
    $.unsubscribe "hover.#{@cid}.figure"
    $.unsubscribe "mouseout.#{@cid}.figure"
    @remove()

  yAxisLabel: ->

    achievement_type = Visio.Utils.humanMetric Visio.manager.get 'achievement_type'
    return @templateLabel
        title: 'Achievement',
        subtitles: ['% of Progress', "towards #{achievement_type}"]
