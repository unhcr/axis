# Indicator Criticality Multiple Year
class Visio.Figures.Icmy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ICMY

  initialize: (config) ->
    @filters = new Visio.Collections.FigureFilter([
    ])

    super config

    @x = d3.scale.ordinal()
      .rangePoints([0, @adjustedWidth])
      .domain(Visio.manager.get('yearList'))

    @y = d3.scale.linear()
      .domain([0, 1])
      .range([@adjustedHeight, 0])

    @lineFn = d3.svg.line()
      .x((d) => @x(d.year))
      .y((d) => @y(d.amount))

    @domain = null

    @voronoiFn = d3.geom.voronoi()
      .x((d) => @x(d.year))
      .y((d) => @y(d.amount))
      .clipExtent([[-@margin.left, -@margin.top], [@adjustedWidth + @margin.right, @adjustedHeight + @margin.bottom]])

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
      .tickFormat(Visio.Formats.PERCENT)
      .tickPadding(20)

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")
      .append("text")


  render: ->
    filtered = @filtered @collection

    lines = @g.selectAll('.ic-line').data(filtered, (d) -> d.category)
    lines.enter().append 'path'
    lines
      .each((d) -> d.sort((a, b) -> a.year - b.year))
      .attr('class', (d) -> ['ic-line', "ic-line-#{d.category}", d.category].join(' '))
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('d', (d) => if d.length then @lineFn(d) else 'M0 0')

    lines.exit().remove()

    voronoi = @g.selectAll('.voronoi').data(@voronoiFn(_.flatten(filtered)))
    voronoi.enter().append('path')
    voronoi.attr('class', (d, i) -> 'voronoi')
      .attr('d', @polygon)

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

    @

  mapFn: (lineData, idx, memo) =>
    _.each lineData, (d) ->
      d.amount /= memo["amount#{d.year}"]
      d.amount = 0 if _.isNaN d.amount
    lineData

  reduceFn: (memo, model) =>
    filters = new Visio.Collections.FigureFilter [{
        id: 'is_performance'
        filterType: 'radio'
        values: { true: false, false: true }
      }]

    _.each Visio.manager.get('yearList'), (year) ->

      return if year + 1 > (new Date()).getFullYear()

      situationAnalysis = model.selectedSituationAnalysis year, filters



      # Keeps track of total in that year
      memo["amount#{year}"] = 0 unless memo["amount#{year}"]?
      memo["amount#{year}"] += situationAnalysis.total

      for category, count of situationAnalysis.counts
        lineData = _.find memo, (d) -> d.category == category

        # Keeps track of total in that category
        lineData.amount += count

        datum = _.findWhere lineData, { year: year, category: category }
        found = datum?

        datum or= { amount: 0, year: year, category: category }

        # Keeps track of total in that year for that category
        datum.amount += count

        lineData.push datum unless found

    return memo

  filtered: (collection) =>
    categories = [
      Visio.Algorithms.ALGO_RESULTS.success,
      Visio.Algorithms.ALGO_RESULTS.ok,
      Visio.Algorithms.ALGO_RESULTS.fail,
      Visio.Algorithms.STATUS.missing,
    ]

    memo = []
    _.each categories, (category) ->
      lineData = []
      lineData.category = category
      lineData.amount = 0
      memo.push lineData

    _.chain(collection.models).reduce(@reduceFn, memo).map(@mapFn).value()

  polygon: (d) ->
    return "M0 0" unless d? and d.length
    "M" + d.join("L") + "Z"

  select: (e, d, i) =>
    line = @g.select(".ic-line-#{d.category}")
    isActive = line.classed 'active'
    line.classed 'active', not isActive
