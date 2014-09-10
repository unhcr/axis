class Visio.Figures.Absy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ABSY

  templateTooltip: HAML['tooltips/absy']

  initialize: (config = {}) ->
    @attrConfig.push 'algorithm'
    config.query or= ''

    values = {}
    values[Visio.Scenarios.AOL] = false
    values[Visio.Scenarios.OL] = true

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
            @xAxis.tickFormat Visio.Formats.PERCENT_NOSIGN
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
        values: performanceValues
        human: { true: 'performance', false: 'impact' }
        hidden: Visio.manager.get('indicator')?
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

    @tickPadding = 20

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
      .tickFormat((d) -> if d == 0 then null else Visio.Formats.SI_SIMPLE(d))
      .innerTickSize(14)
      .ticks(6)
      .tickPadding(@tickPadding)
      .tickSize(-@adjustedHeight)

    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient('left')
      .ticks(5)
      .tickFormat((d) -> return d * 100)
      .tickPadding(@tickPadding)
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
        .attr("y", -60)
        .attr('transform', "translate(-#{@tickPadding}, 0)")
        .attr("dy", "-.21em")
        .style("text-anchor", "end")
        .html =>
          @yAxisLabel()

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")
      .append("text")
        .attr('y', 35)
        .attr('transform', "translate(-#{@tickPadding}, 0)")
        .attr("dy", "-.21em")
        .style("text-anchor", "end")
        .html =>
          @xAxisLabel()

    # Legend setup
    if @isPdf
      @legendView = new Visio.Legends.AbsyPdf
        figure: @
    else
      @legendView = new Visio.Legends.Absy()

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
    pointContainers
        .attr('class', (d) ->
          classList = ['point-container', "id-#{d.refId()}"]

          if self.isQueried d
            classList.push 'queried'

          if self.isPdf and self.isSelected(d.id)
            classList.push 'active'
            d3.select(@).moveToFront()
          return classList.join(' '))
        .each((d, i) ->

          pointContainer = d3.select @
          nIndicators = d.selectedIndicatorData(Visio.manager.year(), self.filters).length
          radius = self.r nIndicators
          achievement = d.selectedAchievement(Visio.manager.year(), self.filters).result
          cxValue = d[self.algorithm](Visio.manager.year(), self.filters)

          pointContainer.attr 'original-title', self.templateTooltip
            d: d
            xValue: if self.algorithm == 'selectedBudget' then Visio.Formats.MONEY(cxValue) else
              Visio.Formats.PERCENT(cxValue)
            achievement: Visio.Formats.PERCENT(achievement)
            algorithm: self.algorithmToHuman(self.algorithm)
            nIndicators: nIndicators

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
          # Hack for when we move from one to voronoi to another to which fires enter, enter, out in Chrome
          pointContainer = @g.select(".point-container.id-#{d.point.refId()}")
          $(pointContainer.node()).tipsy('show')

          pointContainer.moveToFront()
          pointContainer.classed 'focus', true
        ).on('mouseout', (d) =>
          pointContainer = @g.select(".point-container.id-#{d.point.refId()}")
          pointContainer.classed 'focus', false
          $(pointContainer.node()).tipsy('hide')

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
      .html =>
        @xAxisLabel()

    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)

    @g.select('.y.axis text')
      .html =>
        @yAxisLabel()

    # Generate legend view
    if @isPdf
      @legendView.collection = new @collection.constructor(_.filter(filtered, (d) => self.isSelected(d.id)))

    @$el.find('.legend-container').html @legendView.render().el unless @isExport

    @$el.find('.point-container').tipsy()

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

  xAxisLabel: ->
    title = @algorithmToHuman()
    return @templateLabel { title: title, subtitles: ['in US Dollars'] }

  algorithmToHuman: ->
    if @algorithm == 'selectedBudget'
      title = 'Budget'
    else
      title = 'Expenditure Rate (%)'

  yAxisLabel: ->

    achievement_type = Visio.Utils.humanMetric Visio.manager.get 'achievement_type'
    return @templateLabel {
        title: 'Achievement',
        subtitles: ['% of Progress', "towards #{achievement_type}"]
      }
