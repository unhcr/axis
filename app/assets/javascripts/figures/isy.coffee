class Visio.Figures.Isy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ISY

  attrAccessible: ['x', 'y', 'width', 'height', 'collection', 'margin', 'goalType', 'isPerformance']

  initialize: (config) ->
    @$el.prepend $('<a class="export">export</a>')

    super config

    @tooltip = null

    @isPerformance = if config.isPerformance? then config.isPerformance else true

    @barWidth = 10
    @barMargin = 8

    @x = d3.scale.linear()
      .domain([0, @adjustedWidth / ((2 * @barWidth) + @barMargin)])
      .range([0, @adjustedWidth])

    @y = d3.scale.linear()
      .range([@adjustedHeight, 0])
      .clamp(true)

    @goalType = config.goalType || Visio.Algorithms.GOAL_TYPES.target

    @progress =
      start: Visio.Algorithms.REPORTED_VALUES.baseline
      end: Visio.Algorithms.REPORTED_VALUES.myr


  render: ->
    filtered = @filtered @collection

    self = @

    boxes = @g.selectAll('g.box').data filtered, (d) -> d.id
    boxes.enter().append('g')
    boxes.attr('class', (d) -> ['box', "box-#{d.id}"].join(' '))
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

        container.on 'mouseover', (d) ->
          self.g.selectAll('.box').classed 'faded', true
          box.classed 'faded', false

          self.tooltip = new Visio.Views.IsyTooltip
            figure: self
            isyIndex: i
            model: d

          self.y.domain [0, +d.get(self.goalType)]
          circles = box.selectAll('.circle').data(_.values(Visio.Algorithms.REPORTED_VALUES))
          circles.enter().append('circle')
          circles.attr('r', 0)
            .attr('cx', self.barWidth)
            .attr('cy', (reportedValue) -> self.y(d.get(reportedValue)))
            .attr('class', 'circle')
          circles.transition()
            .duration(Visio.Durations.VERY_FAST)
            .attr('r', self.barWidth / 2)

          # can't be in box svg since it need to be top level element
          labels = self.g.selectAll('.label')
            .data(_.values(Visio.Algorithms.REPORTED_VALUES).concat(Visio.Algorithms.GOAL_TYPES.target))
          labels.enter().append('g')

          labels
            .attr('class', 'label')
            .attr('transform', (type) ->
              i = $(self.g.selectAll('.box')[0]).index(box[0][0])
              "translate(#{self.x(i) + self.barWidth * 3}, #{self.y(d.get(type))})"
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
                    percent = d.get(p) / +d.get(self.goalType)
                    humanMetric = Visio.Utils.humanMetric(p)
                    return "#{Visio.Formats.PERCENT(percent)} #{humanMetric}"
                  else
                    return "#{humanGoal} is #{d.get(self.goalType)}"


        container.on 'mouseout', (d) ->
          self.tooltip.close() if self.tooltip?
          self.g.selectAll('.box').classed 'faded', false
          box.selectAll('.circle').data([])
            .exit().transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
          self.g.selectAll('.label').remove()

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
          ).attr('x', idx * self.barWidth)

          bars.transition()
            .duration(Visio.Durations.FAST)
            .attr('y', (d) ->
              if reversed
                return self.y(value + barHeight)
              else
                return self.y(baseline + barHeight)
            ).attr('width', self.barWidth)
            .attr('height', (d) ->
              return self.y(0) - self.y(barHeight))
          bars.exit().remove()

        max = d3.max metrics, (metric) ->
          +d.get(metric)

        reversed = baseline > max

        box.classed 'reversed', reversed

        center = box.selectAll('.center').data([d])
        center.enter().append('line')
        center.attr('class', 'center')
        center.transition()
          .duration(Visio.Durations.FAST)
          .attr('x1', self.barWidth)
          .attr('y1', (d) -> if reversed then self.y(baseline) else self.y(max))
          .attr('x2', self.barWidth)
          .attr('y2', (d) -> self.y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
        center.exit().remove()

        whisker = box.selectAll('.whisker').data([d])
        whisker.enter().append('line')
        whisker.attr('class', 'whisker')
        whisker.transition()
          .duration(Visio.Durations.FAST)
          .attr('x1', self.barWidth / 2 + 2)
          .attr('y1', (d) -> self.y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
          .attr('x2', 1.5 * self.barWidth - 2)
          .attr('y2', (d) -> self.y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
        whisker.exit().remove()

      )
    boxes.on 'click', (d, i) =>
      $.publish "select.#{@figureId()}", [d, i]

    boxes.exit().remove()
    @

  sortFn: (a, b) =>
    reversedA = if a.get(@progress.start) > a.get(@progress.end) then -1 else 1
    reversedB = if b.get(@progress.start) > b.get(@progress.end) then -1 else 1
    (reversedA * @scaledBarHeight(a)) - (reversedB * @scaledBarHeight(b))

  filterFn: (d) => d.get('is_performance') == @isPerformance

  scaledBarHeight: (d) =>
    @y.domain [0, +d.get(@goalType)]
    v = Math.abs(+d.get(@progress.start) - +d.get(@progress.end))

  filtered: (collection) => _.chain(collection.models).filter(@filterFn).sort(@sortFn).value()

  select: (e, d, i) =>
    box = @g.select(".box-#{d.id}")
    isActive = box.classed 'active'
    box.classed 'active', not isActive


