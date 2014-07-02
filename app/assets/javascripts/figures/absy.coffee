class Visio.Figures.Absy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ABSY

  initialize: (config) ->
    @attrConfig.push 'algorithm'
    config.query or= ''

    values = {}
    values[Visio.Scenarios.AOL] = false
    values[Visio.Scenarios.OL] = true
    @filters = new Visio.Collections.FigureFilter([
      {
        id: 'algorithm'
        filterType: 'radio'
        values: {
          selectedBudget: true,
          selectedExpenditureRate: false
        }
        human: { selectedExpenditureRate: 'Expenditure Rate', selectedBudget: 'Budget' }
        callback: (name, attr) =>
          @algorithm = name
          if @algorithm == 'selectedBudget'
            @xAxis.tickFormat Visio.Formats.SI_SIMPLE
          else
            @xAxis.tickFormat Visio.Formats.PERCENT
          @render()

      }
      {
        id: 'budget_type'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Budgets), _.values(Visio.Budgets).map(-> true))
      },
      {
        id: 'scenario'
        filterType: 'checkbox'
        values: values
      },
      {
        id: 'is_performance'
        filterType: 'radio'
        values: { true: false, false: true }
        human: { true: 'performance', false: 'impact' }
      },
      {
        id: 'achievement'
        filterType: 'radio'
        values: _.object(_.values(Visio.Algorithms.GOAL_TYPES), _.values(Visio.Algorithms.GOAL_TYPES).map(
          (achievement_type) ->
            Visio.manager.get('achievement_type') == achievement_type))
        callback: (name, attr) ->
          Visio.manager.set('achievement_type', name)
      }
    ])

    super config

    @algorithm or= 'selectedBudget'

    @x = d3.scale.linear()
      .range([0, @adjustedWidth])

    @y = d3.scale.linear()
      .domain([0, 1])
      .range([@adjustedHeight, 0])

    @r = d3.scale.sqrt()
      .domain([0, 100])
      .range([2, 32])

    @xAxis = d3.svg.axis()
      .scale(@x)
      .orient('bottom')
      .tickFormat(Visio.Formats.SI_SIMPLE)
      .ticks(Math.floor(@adjustedWidth / 100))
      .innerTickSize(14)

    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient('left')
      .ticks(5)
      .tickFormat((d) -> return d * 100)
      .tickPadding(20)
      .tickSize(-@adjustedWidth)

    @domain = null
    @entered = false

    @info = null
    @voronoi = d3.geom.voronoi()
      .clipExtent([[0, 0], [@adjustedWidth, @adjustedHeight]])
      .x((d) => @x(d[@algorithm](Visio.manager.year(), @filters)))
      .y((d) => @y(d.selectedAchievement(Visio.manager.year(), @filters).result))

    @shadowWidth = 3

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", -40)
        .attr("x", -@adjustedHeight / 2)
        .attr("dy", "-.21em")
        .style("text-anchor", "middle")
        .text('Progress Towards Target (%)')

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")
      .append("text")
        .attr('y', 50)
        .attr("x", @adjustedWidth / 2)
        .attr("dy", "-.21em")
        .style("text-anchor", "middle")
        .text =>
          if @algorithm == 'selectedBudget'
            'Budget (Dollars)'
          else
            'Expenditure Rate (%)'

  render: ->
    filtered = @filtered @collection

    if @algorithm == 'selectedBudget'
      maxAmount = d3.max filtered, (d) => d[@algorithm](Visio.manager.year(), @filters)
    else
      maxAmount = 1

    self = @
    if !@domain || @domain[1] < maxAmount || @domain[1] > 2 * maxAmount
      @domain = [0, maxAmount]
      @x.domain(@domain)

    pointContainers = @g.selectAll('.point-container').data(filtered, (d) -> d.refId())
    pointContainers.enter().append('g')
    pointContainers.attr('class', (d, i) ->
          classList = ['point-container', "id-#{d.refId()}"]

          if self.isQueried d
            classList.push 'queried'

          if self.isPdf and self.isSelected(d.id)
            classList.push 'active'
            d3.select(@).moveToFront()
          return classList.join(' '))
        .each((d, i) ->

          pointContainer = d3.select @
          radius = self.r d.selectedIndicatorData(Visio.manager.year(), self.filters).length
          achievement = d.selectedAchievement(Visio.manager.year(), self.filters).result
          cxValue = d[self.algorithm](Visio.manager.year(), self.filters)

          pointShadows = pointContainer.selectAll('.point-shadow').data([d])
          pointShadows.enter().append('circle')
          pointShadows.attr('class', (d) ->
            classList = ['point-shadow']
            return classList.join(' '))
          pointShadows
            .transition()
            .duration(Visio.Durations.FAST)
            .attr('r', (d) =>
              value = radius + self.shadowWidth
              if (self.isPdf and self.isSelected(d.id)) or self.isQueried(d)
                value += 4
              value
            )
            .attr('cy', (d) =>
              return self.y(achievement))
            .attr('cx', (d) =>
              return self.x(cxValue))

          pointShadows.exit().transition().duration(Visio.Durations.FAST).attr('r', 0).remove()

          # Points
          point = pointContainer.selectAll('.point').data([d])
          point.enter().append('circle')
          point
            .attr('class', (d) ->
              classList = ['point']
              classList.push 'external' unless Visio.manager.get('dashboard')?.include d.name.singular, d.id
              return classList.join(' '))
          point
            .transition()
            .duration(Visio.Durations.FAST)
            .attr('r', (d) =>
              if self.isPdf and self.isSelected(d.id)
                radius += 4
              radius
            )
            .attr('cy', (d) =>
              return self.y(achievement))
            .attr('cx', (d) =>
              return self.x(cxValue))

          point.exit().transition().duration(Visio.Durations.FAST).attr('r', 0).remove()


          # Conditional Labels
          if self.isExport
            labels = pointContainer.selectAll('.label').data([d])
          else if self.isPdf and not _.isEmpty self.selected
            labels = pointContainer.selectAll('.label').data(_.filter([d], (d) => self.isSelected(d.id)))

          if self.isExport or (self.isPdf and not _.isEmpty self.selected)
            labels.enter().append('text')
            labels.attr('class', 'label')
              .attr('x', (d) => self.x(d[self.algorithm](Visio.manager.year(), self.filters)))
              .attr('y', (d) => self.y(d.selectedAchievement(Visio.manager.year(), self.filters).result))
              .attr('dy', '.3em')
              .attr('text-anchor', 'middle')
              .text((d) ->
                if self.isPdf
                  Visio.Constants.ALPHABET[_.indexOf self.selected, "#{d.id}"]
                else
                  Visio.Constants.ALPHABET[i]
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
            filters: @filters
          })
          # Hack for when we move from one to voronoi to another to which fires enter, enter, out in Chrome
          window.setTimeout(( -> @entered = false), 50)
          @info.render(d.point, @algorithm)
          @info.show()
          pointContainer = @g.select(".point-container.id-#{d.point.refId()}")
          pointContainer.moveToFront()
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

    @g.select('.x.axis text')
      .text =>
        if @algorithm == 'selectedBudget'
          'Budget (Dollars)'
        else
          'Expenditure Rate (%)'

    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)

    # Generate legend view
    if @isPdf
      @legendView = new Visio.Figures.AbsyLegend
        figure: @
        collection: new @collection.constructor(_.filter(filtered, (d) => self.isSelected(d.id)))
      @$el.find('.legend-container').html @legendView.render().el


    @


  filterFn: (d) =>
    d[@algorithm](Visio.manager.year(), @filters) && d.selectedAchievement(Visio.manager.year(), @filters).result >= 0

  filtered: (collection) => _.chain(collection.models).filter(@filterFn).value()

  polygon: (d) ->
    return "M0 0" unless d? and d.length
    "M" + d.join("L") + "Z"

  select: (e, d, i) =>
    pointContainer = @g.select(".point-container.id-#{d.refId()}")
    console.warn 'Selected element is empty' if pointContainer.empty()
    isActive = pointContainer.classed 'active'
    pointContainer.classed 'active', not isActive

  isSelected: (id) =>
    _.include @selected, "#{id}"

  isQueried: (d) =>
    !_.isEmpty(@query) and d.toString().toLowerCase().indexOf(@query.toLowerCase()) != -1
