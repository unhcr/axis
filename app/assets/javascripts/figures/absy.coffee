class Visio.Figures.Absy extends Visio.Figures.Base

  type: Visio.FigureTypes.ABSY

  initialize: (config) ->
    @$el.prepend $('<a class="export">export</a>')
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
      },
      {
        id: 'achievement'
        filterType: 'radio'
        values: _.object(_.values(Visio.AchievementTypes), _.values(Visio.AchievementTypes).map(
          (achievement_type) ->
            Visio.manager.get('achievement_type') == achievement_type))
        callback: (name, attr) ->
          Visio.manager.set('achievement_type', name)
      }
    ])

    super config


    @x = d3.scale.linear()
      .range([0, @adjustedWidth])

    @y = d3.scale.linear()
      .domain([0, 1])
      .range([@adjustedHeight, 0])

    @r = d3.scale.sqrt()
      .domain([0, 1000000])
      .range([0, 20])

    @xAxis = d3.svg.axis()
      .scale(@x)
      .orient('bottom')
      .tickFormat(d3.format('s'))
      .ticks(6)
      .innerTickSize(14)

    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient('left')
      .ticks(5)
      .tickFormat((d) -> return if d then d * 100 else '0%')
      .innerTickSize(14)
      .tickPadding(20)

    @domain = null
    @entered = false

    @info = null
    @voronoi = d3.geom.voronoi()
      .clipExtent([[0, 0], [@adjustedWidth, @adjustedHeight]])
      .x((d) => @x(d.selectedAmount(false, @filters)))
      .y((d) => @y(d.selectedAchievement(false, @filters).result))

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 0)
        .attr("x", -@adjustedHeight)
        .attr("dy", "-.21em")
        .style("text-anchor", "start")
        .text('Acheivement')

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")
      .append("text")
        .attr("x", @adjustedWidth + 10)
        .attr("dy", "-.21em")
        .style("text-anchor", "start")
        .text('Budget')

  render: ->
    filtered = @filtered @collection
    maxAmount = d3.max filtered, (d) => d.selectedAmount(false, @filters)

    if !@domain || @domain[1] < maxAmount || @domain[1] > 2 * maxAmount
      @domain = [0, maxAmount]
      @x.domain(@domain)

    bubbles = @g.selectAll('.bubble').data(filtered, (d) -> d.refId())
    bubbles.enter().append('circle')
    bubbles
      .attr('class', (d) ->
        return ['bubble', "id-#{d.refId()}"].join(' '))
    bubbles
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('r', (d) =>
        return @r(600000))
      .attr('cy', (d) =>
        return @y(d.selectedAchievement(false, @filters).result))
      .attr('cx', (d) =>
        return @x(d.selectedAmount(false, @filters)))

    bubbles.exit().transition().duration(Visio.Durations.FAST).attr('r', 0).remove()

    if @isExport
      labels = @g.selectAll('.label').data(filtered, (d) -> d.refId())
      labels.enter().append('text')
      labels.attr('class', 'label')
        .attr('x', (d) => @x(d.selectedAmount(false, @filters)))
        .attr('y', (d) => @y(d.selectedAchievement(false, @filters).result))
        .attr('dy', '.3em')
        .attr('text-anchor', 'middle')
        .text((d, i) -> i + 1)


    path = @g.selectAll('.voronoi')
      .data(@voronoi(filtered))

    path.enter().append("path")
    path.attr("class", (d, i) -> "voronoi" )
        .attr("d", @polygon)
        .on('mouseenter', (d) =>
          @entered = true
          @info or= new Visio.Views.BubbleInfoView({
            el: $('.info-container .bubble-info')
          })
          # Hack for when we move from one to voronoi to another to which fires enter, enter, out in Chrome
          window.setTimeout(( -> @entered = false), 50)
          @info.render(d.point)
          @info.show()
          bubble = @g.select(".bubble.id-#{d.point.refId()}")
          bubble.moveToFront() unless @isExport
          bubble.classed 'focus', true
        ).on('mouseout', (d) =>
          @info.hide() if @info and not @entered
          @g.select(".bubble.id-#{d.point.refId()}").classed 'focus', false

        ).on('click', (d, i) =>
          $.publish "select.#{@figureId()}", [d.point, i]
        )

    path.exit().remove()

    @g.select('.x.axis')
      .transition()
      .delay(Visio.Durations.FAST)
      .duration(Visio.Durations.FAST)
      .call(@xAxis)

    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)
      .attr('transform', 'translate(-20,0)')

    @


  filterFn: (d) ->
    d.selectedAmount(false, @filters) && d.selectedAchievement(false, @filters).result

  filtered: (collection) => _.chain(collection.models).filter(@filterFn).value()

  polygon: (d) ->
    return "M0 0" unless d? and d.length
    "M" + d.join("L") + "Z"

  select: (e, d, i) =>
    bubble = @g.select(".bubble.id-#{d.refId()}")
    isActive = bubble.classed 'active'
    bubble.classed 'active', not isActive
