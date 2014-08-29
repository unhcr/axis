class Visio.Figures.Bsy extends Visio.Figures.Base
  # Budget Single Year Figure
  # Data: Collection of parameters (operation, ppg, etc.)

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.BSY

  initialize: (config) ->
    # Stores the query of a certain operation. 'ken' will match the Kenya operation
    config.query or= ''

    scenarioExpenditures = {}
    scenarioExpenditures[Visio.Scenarios.AOL] = false
    scenarioExpenditures[Visio.Scenarios.OL] = true

    @filters = new Visio.Collections.FigureFilter([
      {
        id: 'breakdown_by'
        filterType: 'radio'
        values:
          budget_type: true
          pillar: false
        callback: (name, attr) =>
          @breakdownBy = name
          @render()
      },
      {
        id: 'budget_type'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Budgets), _.values(Visio.Budgets).map(-> true))
      },
      {
        id: 'pillar'
        filterType: 'checkbox'
        values: _.object(_.keys(Visio.Pillars), _.keys(Visio.Pillars).map(-> true))
        human: Visio.Pillars
      },
      {
        id: 'scenarios-budgets'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Scenarios), _.values(Visio.Scenarios).map(-> true))
        callback: (name, attr) =>
          @render()
      },
      {
        id: 'scenarios-expenditures'
        filterType: 'checkbox'
        values: scenarioExpenditures
        callback: (name, attr) =>
          @render()
      }
    ])

    super config

    # Determines the breakdown of the stack graph. Either budget type or pillar
    @breakdownBy = 'budget_type'

    @tooltip = new Visio.Views.BsyTooltip
      figure: @

    @$el.find('.tooltip-container').html @tooltip.el

    @barWidth = 10
    @barMargin = 8

    @x = d3.scale.linear()
      .range([0, @adjustedWidth])

    @y = d3.scale.linear()
      .range([@adjustedHeight, 0])

    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient('left')
      .ticks(5)
      .tickFormat(Visio.Formats.LONG_MONEY)
      .tickSize(-@adjustedWidth)

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")
        .attr("y", -10)
        .attr("x", 40)
        .attr("dy", "-.21em")

    $.subscribe "hover.#{@cid}.figure", @hover
    $.subscribe "mouseout.#{@cid}.figure", @mouseout

    $(@svg.node()).parent().on 'mouseleave', =>
      $.publish "hover.#{@cid}.figure", [@selectedDatum, true] if @selectedDatum

  render: ->
    filtered = @filtered @collection

    # Check to see if domain was set already
    # Expensive computation so don't want to repeat if not necessary
    @y.domain [0, d3.max(filtered, (d) -> d.selectedBudget(Visio.manager.year(), @filters))]


    self = @

    scenarios = self.filters.get('scenarios-budgets').active().map (scenario) ->
        { scenario: scenario, type: Visio.Syncables.BUDGETS }

    scenarios = scenarios.concat(self.filters.get('scenarios-expenditures').active().map (scenario) ->
        { scenario: scenario, type: Visio.Syncables.EXPENDITURES })

    @maxParameters = Math.floor @adjustedWidth / (scenarios.length * @barWidth + @barMargin)
    @x.domain([0, @maxParameters])

    boxes = @g.selectAll('g.box').data filtered, (d) -> d.id
    boxes.enter().append('g')
    boxes.attr('class', (d) -> ['box', "box-#{d.id}"].join(' '))
      .style('opacity', (d, i) -> if self.x(i) < 0 then 0 else 1)
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('transform', (d, i) -> 'translate(' + self.x(i) + ', 0)')
      .each((d, idx) ->
        box = d3.select @


        container = box.selectAll('.bar-container').data([d])
        container.enter().append('rect')
        container.attr('width', self.barWidth * scenarios.length)
          .attr('height', self.adjustedHeight + self.barMargin)
          .attr('x', 0)
          .attr('y', -self.barMargin / 2)
          .attr('class', (d) ->
            classList = ['bar-container']
            classList.push 'selected' if d.id == self.selectedDatum?.id
            classList.push 'hover' if d.id == self.hoverDatum?.id

            return classList.join ' ')
          .style('stroke-dasharray', (d) ->
            topDash = self.barWidth * scenarios.length
            perimeter = (self.barWidth * 2 * scenarios.length) + ((self.height + self.barMargin) * 2)

            [topDash, perimeter - topDash].join ' ' )

        container.on 'mouseenter', (d) ->
          $.publish "hover.#{self.cid}.figure", [idx, false]

        container.on 'mouseout', (d) ->
          $.publish "mouseout.#{self.cid}.figure", idx

        container.exit().remove()

        box.selectAll('.bar').remove()
        _.each scenarios, (scenario, i) ->
          amountData = d.selectedData(scenario.type, Visio.manager.year(), self.filters).where
            scenario: scenario.scenario

          breakdownTypes = self.breakdownTypes()
          sum = 0

          _.each breakdownTypes, (breakdownType, j) ->
            # data for scenario and breakdownType
            breakdownData = _.filter amountData, (datum) ->
              datum.get(self.breakdownBy) == breakdownType

            amount = new Visio.Collections.AmountType(breakdownData).amount()

            bars = box.selectAll(".#{Visio.Utils.stringToCssClass(scenario.scenario)}-bar.#{Visio.Utils.stringToCssClass(breakdownType)}-bar.#{scenario.type.singular}-bar").data([breakdownType])
            bars.enter().append('rect')
            bars.attr 'class', ->
              classList = ["#{Visio.Utils.stringToCssClass(scenario.scenario)}-bar",
                "#{Visio.Utils.stringToCssClass(breakdownType)}-bar",
                "#{scenario.type.singular}-bar",
                'bar']
              classList.join ' '

            bars.transition()
              .duration(Visio.Durations.FAST)
              .attr('x', -> i * self.barWidth)
              .attr('width', -> self.barWidth)
              .attr('y', -> self.y(amount + sum))
              .attr('height', -> self.adjustedHeight - self.y(amount))

            sum += amount

            bars.exit().remove()
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
    @

  transformSortFn: (a, b) =>
    elA = @g.select ".box-#{a.id}"
    elB = @g.select ".box-#{b.id}"
    transformA = Visio.Utils.parseTransform elA.attr('transform')
    transformB = Visio.Utils.parseTransform elB.attr('transform')

    transformA.translate[0] - transformB.translate[0]

  queryByFn: (d) =>
    _.isEmpty(@query) or d.toString().toLowerCase().indexOf(@query.toLowerCase()) != -1

  sortFn: (a, b) =>
    b.selectedBudget() - a.selectedBudget()

  filtered: (collection) =>
    _.chain(collection.models).filter(@queryByFn).sort(@sortFn).value()

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

    if _.isNumber idxOrDatum
      idx = idxOrDatum
      result = @findBoxByIndex idx
    else
      @hoverDatum = idxOrDatum
      result = @findBoxByDatum @hoverDatum

    box = result.box
    idx = result.idx
    @hoverDatum = result.datum

    return unless @hoverDatum?
    box.select('.bar-container').classed 'hover', true

    if idx >= @maxParameters and scroll
      difference = idx - @maxParameters
      @x.domain [0 + difference, @maxParameters + difference]
      @g.selectAll('g.box')
        .transition()
        .duration(Visio.Durations.VERY_FAST)
        .attr('transform', (d, i) => 'translate(' + @x(i) + ', 0)')
        .style('opacity', (d, i) -> if self.x(i) < 0 then 0 else 1)
    else if @x.domain()[0] > 0 and scroll
      @x.domain [0, @maxParameters]
      @g.selectAll('g.box')
        .transition()
        .duration(Visio.Durations.VERY_FAST)
        .attr('transform', (d, i) => 'translate(' + @x(i) + ', 0)')
        .style('opacity', (d, i) -> if self.x(i) < 0 then 0 else 1)

    @g.selectAll('.circle').data([])
      .exit().transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    @g.selectAll('.label').remove()

    @tooltip.render @hoverDatum

    budgetData = @hoverDatum.selectedBudgetData()
    ol = new Visio.Collections.AmountType(budgetData.where({ scenario: Visio.Scenarios.OL })).amount()
    aol = new Visio.Collections.AmountType(budgetData.where({ scenario: Visio.Scenarios.AOL })).amount()
    circleData = [ol, aol]

    circles = box.selectAll('.circle').data(circleData)
    circles.enter().append('circle')
    circles.attr('r', 0)
      .attr('cx', @barWidth)
      .attr('cy', (value) =>
        @y(value))
      .attr('class', 'circle')
    circles.transition()
      .duration(Visio.Durations.VERY_FAST)
      .attr('r', @barWidth / 2)

    labelData = circleData
    labelHeight = 20

    box.moveToFront()

  breakdownTypes: =>
    if @breakdownBy == 'budget_type'
      _.values Visio.Budgets
    else if @breakdownBy == 'pillar'
      _.keys Visio.Pillars

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
