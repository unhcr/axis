class Visio.Figures.Bmy extends Visio.Figures.Exportable

  type: Visio.FigureTypes.BMY

  initialize: (config) ->
    @filters = new Visio.Collections.FigureFilter([
      {
        id: 'budget_type'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Budgets), _.values(Visio.Budgets).map(-> true))
      },
      {
        id: 'scenario'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Scenarios), _.values(Visio.Scenarios).map(-> true))
      }
    ])

    Visio.Figures.Exportable.prototype.initialize.call @, config

    @tooltip = null

    self = @
    @svg.on('mouseleave', () ->
      self.tooltip.close() if self.tooltip?
      self.tooltip = null
      d3.select(@).selectAll('.point').transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    )


    @x = d3.scale.ordinal()
      .rangePoints([0, @width])
      .domain(Visio.manager.get('yearList'))

    @y = d3.scale.linear()
      .range([@height, 0])

    @lineFn = d3.svg.line()
      .x((d) => @x(d.year))
      .y((d) => @y(d.amount))

    @domain = null

    @voronoiFn = d3.geom.voronoi()
      .x((d) => @x(d.year))
      .y((d) => @y(d.amount))
      .clipExtent([[-@margin.left, -@margin.top], [@width + @margin.right, @height + @margin.bottom]])

    @isExport = if config.isExport? then config.isExport else false

    @xAxis = d3.svg.axis()
      .scale(@x)
      .orient('bottom')
      .ticks(6)
      .innerTickSize(14)

    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient('left')
      .ticks(5)
      .innerTickSize(14)
      .tickPadding(20)

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@height})")
      .append("text")



  render: ->
    filtered = @filtered @data
    @y.domain [0, d3.max(_.flatten(filtered), (d) -> d.amount)]

    lines = @g.selectAll('.budget-line').data(filtered, (d) -> d.budgetType)
    lines.enter().append 'path'
    lines
      .each((d) -> d.sort((a, b) -> a.year - b.year))
      .attr('class', (d) -> ['budget-line', "budget-line-#{d.budgetType}", d.budgetType].join(' '))
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('d', (d) => if d.length then @lineFn(d) else 'M0 0')

    lines.exit().remove()

    # For selecting line segments

    voronoi = @g.selectAll('.voronoi').data(@voronoiFn(_.flatten(filtered)))
    voronoi.enter().append('path')
    voronoi.attr('class', (d, i) -> 'voronoi')
      .attr('d', @polygon)
      .on('mouseenter', (d) =>
        pointData = _.chain(filtered).flatten().where({ year: d.point.year }).value()
        points = @g.selectAll('.point').data pointData
        points.enter().append 'circle'
        points
          .attr('r', 5)
          .attr('class', (d) -> ['point', d.budgetType].join(' '))
        points.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
          .attr('cx', (d) => @x(d.year))
          .attr('cy', (d) => @y(d.amount))
        points.exit().remove()


        if @tooltip?
          @tooltip.year = d.point.year
          @tooltip.collection = new Backbone.Collection(pointData)
          @tooltip.render(true)
        else
          @tooltip = new Visio.Views.BmyTooltip
            figure: @
            year: d.point.year
            collection: new Backbone.Collection(pointData)

      )

    if @isExport
      voronoi.on('click', (d, i) =>
        # ASSUMES DETERMINISTIC FLATTEN FUNCTION
        count = 0
        lineIndex = null
        _.each filtered, (lineArray, lineArrayIndex) ->
          _.each lineArray, (lineDatum) ->
            lineIndex = lineArrayIndex if count == i
            count += 1

        $.publish "select.#{@figureId()}", [d.point, lineIndex])

    voronoi.exit().remove()

    @g.select('.x.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@xAxis)

    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)
      .attr('transform', 'translate(-20,0)')


  reduceFn: (memo, budget) =>
    unless budget.get('year')
      console.warn 'No year for budget: ' + budget.id
      return memo

    # Add budget type array
    lineData = _.find memo, (array) -> array.budgetType == budget.get 'budget_type'
    unless lineData
      lineData = []
      lineData.budgetType = budget.get 'budget_type'
      memo.push lineData unless @filters.get('budget_type').isFiltered budget

    return memo if @filters.get('budget_type').isFiltered budget

    # Add line datum
    datum = _.findWhere lineData, { year: budget.get 'year' }
    unless datum
      datum = { amount: 0, year: budget.get('year'), budgetType: budget.get('budget_type') }
      lineData.push datum unless @filters.get('scenario').isFiltered budget

    return memo if @filters.get('scenario').isFiltered budget
    datum.amount += budget.get 'amount'

    # Add 'total' array
    totalData = _.find memo, (array) -> array.budgetType == 'total'
    unless totalData
      totalData = []
      totalData.budgetType = 'total'
      memo.push totalData

    # Add total datum
    total = _.findWhere totalData, { year: budget.get 'year' }
    unless total
      total = { amount: 0, year: budget.get('year'), budgetType: 'total' }
      totalData.push total
    total.amount += budget.get 'amount'

    return memo

  filtered: (data) => _.chain(data).reduce(@reduceFn, []).value()

  polygon: (d) ->
    return "M0 0" unless d? and d.length
    "M" + d.join("L") + "Z"

  select: (e, d, i) =>
    line = @g.select(".budget-line-#{d.budgetType}")
    isActive = line.classed 'active'
    line.classed 'active', not isActive

  filter: (type, attr, active) =>
    @filters[type].values[attr] = active
