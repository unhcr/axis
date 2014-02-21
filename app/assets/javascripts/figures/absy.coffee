class Visio.Figures.Absy extends Visio.Figures.Base

  type: Visio.FigureTypes.ABSY

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
    @$el.prepend $('<a class="export">export</a>')

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
      .ticks(Math.floor(@adjustedWidth / 100))
      .innerTickSize(14)

    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient('left')
      .ticks(5)
      .tickFormat((d) -> return d * 100)
      .innerTickSize(14)
      .tickPadding(0)

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
        .attr("y", -40)
        .attr("x", -@adjustedHeight / 2)
        .attr("dy", "-.21em")
        .style("text-anchor", "middle")
        .text('Achievement (%)')

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")
      .append("text")
        .attr('y', 50)
        .attr("x", @adjustedWidth / 2)
        .attr("dy", "-.21em")
        .style("text-anchor", "middle")
        .text('Budget (Dollars)')

  render: ->
    filtered = @filtered @collection
    maxAmount = d3.max filtered, (d) => d.selectedAmount(false, @filters)

    self = @
    if !@domain || @domain[1] < maxAmount || @domain[1] > 2 * maxAmount
      @domain = [0, maxAmount]
      @x.domain(@domain)

    pointContainers = @g.selectAll('.point-container').data(filtered, (d) -> d.refId())
    pointContainers.enter().append('g')
    pointContainers.attr('class', (d, i) ->
          classList = ['point-container', "id-#{d.refId()}"]

          if self.isPdf and _.include self.selected, d.id
            classList.push 'active'
            d3.select(@).moveToFront()
          return classList.join(' '))
        .each((d, i) ->

          pointContainer = d3.select @

          # Points
          point = pointContainer.selectAll('.point').data([d])
          point.enter().append('circle')
          point
            .attr('class', (d) ->
              classList = ['point']
              return classList.join(' '))
          point
            .transition()
            .duration(Visio.Durations.FAST)
            .attr('r', (d) =>
              if self.isPdf and _.include self.selected, d.id
                16
              else
                12
            )
            .attr('cy', (d) =>
              return self.y(d.selectedAchievement(false, self.filters).result))
            .attr('cx', (d) =>
              return self.x(d.selectedAmount(false, self.filters)))

          point.exit().transition().duration(Visio.Durations.FAST).attr('r', 0).remove()

          # Conditional Labels
          if self.isExport
            labels = pointContainer.selectAll('.label').data([d])
          else if self.isPdf and not _.isEmpty self.selected
            labels = pointContainer.selectAll('.label').data(_.filter([d], (d) => _.include self.selected, d.id))

          if self.isExport or self.isPdf
            labels.enter().append('text')
            labels.attr('class', 'label')
              .attr('x', (d) => self.x(d.selectedAmount(false, self.filters)))
              .attr('y', (d) => self.y(d.selectedAchievement(false, self.filters).result))
              .attr('dy', '.3em')
              .attr('text-anchor', 'middle')
              .text((d) ->
                if self.isPdf
                  console.log 'pdf'
                  1 + _.indexOf self.selected, d.id
                else
                  i + 1
              )

        )

    pointContainers.exit().remove()

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
          pointContainer = @g.select(".point-container.id-#{d.point.refId()}")
          pointContainer.moveToFront() unless @isExport
          pointContainer.classed 'focus', true
        ).on('mouseout', (d) =>
          @info.hide() if @info and not @entered
          @g.select(".point-container.id-#{d.point.refId()}").classed 'focus', false

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

    # Generate legend view
    if @isPdf
      @legendView = new Visio.Figures.AbsyLegend
        figure: @
        collection: new @collection.constructor(_.filter(filtered, (d) => _.include @selected, d.id))
      @$el.find('.legend-container').html @legendView.render().el


    @


  filterFn: (d) ->
    d.selectedAmount(false, @filters) && d.selectedAchievement(false, @filters).result

  filtered: (collection) => _.chain(collection.models).filter(@filterFn).value()

  polygon: (d) ->
    return "M0 0" unless d? and d.length
    "M" + d.join("L") + "Z"

  select: (e, d, i) =>
    pointContainer = @g.select(".point-container.id-#{d.refId()}")
    console.warn 'Selected element is empty' if pointContainer.empty()
    isActive = pointContainer.classed 'active'
    pointContainer.classed 'active', not isActive
