class Visio.Figures.Absy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ABSY

  templateTooltip: HAML['tooltips/absy']

  containerClass: 'point-container'

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
          selectedBudgetPerBeneficiary: false
        }
        human: { selectedExpenditureRate: 'Expenditure Rate', selectedBudget: 'Budget', selectedBudgetPerBeneficiary: 'Budget Per Beneficiary' }
        callback: (name, attr) =>
          @algorithm = name
          if @algorithm == 'selectedBudget' or @algorithm == 'selectedBudgetPerBeneficiary'
            @xAxis.tickFormat Visio.Formats.SI_SIMPLE
          else
            @xAxis.tickFormat Visio.Formats.PERCENT_NOSIGN
          @render()

      }
      {
        id: 'budget_type'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Budgets), _.values(Visio.Budgets).map(-> true))
        callback: => @render()
      },
      {
        id: 'scenario'
        filterType: 'checkbox'
        values: values
        callback: => @render()
      },
      {
        id: 'is_performance'
        filterType: 'radio'
        values: performanceValues
        human: { true: 'performance', false: 'impact' }
        hidden: Visio.manager.get('indicator')?
        callback: => @render()
      },
      {
        id: 'achievement'
        filterType: 'radio'
        values: _.object(_.values(Visio.Algorithms.GOAL_TYPES), _.values(Visio.Algorithms.GOAL_TYPES).map(
          (achievement_type) ->
            Visio.manager.get('achievement_type') == achievement_type))
        callback: (name, attr) =>
          Visio.manager.set('achievement_type', name)
          @render()
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
        .attr("y", 0)
        .attr('transform', "translate(-#{@tickPadding}, -60)")
        .attr("dy", "-.21em")
        .style("text-anchor", "end")
        .html =>
          @yAxisLabel()

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")
      .append("text")
        .attr('y', 0)
        .attr('transform', "translate(-#{@tickPadding}, 35)")
        .attr("dy", "-.21em")
        .style("text-anchor", "end")
        .html =>
          @xAxisLabel()

  render: ->
    filtered = @filtered @collection

    if @algorithm == 'selectedBudget' or @algorithm == 'selectedBudgetPerBeneficiary'
      maxAmount = d3.max filtered, (d) => d[@algorithm](Visio.manager.year(), @filters)
    else
      maxAmount = 1

    self = @
    if !@domain || @domain[1] < maxAmount || @domain[1] > 2 * maxAmount
      @domain = [0, maxAmount]
      @x.domain(@domain)

    pointContainers = @g.selectAll(".#{@containerClass}").data(filtered, (d) -> d.refId())
    pointContainers.enter().append('g')
    pointContainers
        .attr('class', (d) ->
          classList = [self.containerClass, "id-#{d.refId()}"]
          classList.push 'external' unless Visio.manager.get('dashboard')?.include d.name.singular, d.id

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
            xValue: if self.algorithm == 'selectedBudget' or self.algorithm == 'selectedBudgetPerBeneficiary' then Visio.Formats.MONEY(cxValue) else
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
          if (self.isPdf)
            labels = pointContainer.selectAll('.label').data(_.filter([d], (d) => self.isSelected(d.id)))
            labels.enter().append('text')
            labels.attr('class', 'label')
              .attr('x', (d) => self.x(d[self.algorithm](Visio.manager.year(), self.filters)))
              .attr('y', (d) => self.y(d.selectedAchievement(Visio.manager.year(), self.filters).result))
              .attr('dy', '.3em')
              .attr('text-anchor', 'middle')
              .text((d) ->
                if self.isPdf
                  idx = self.activeData.chain().pluck('id').map(String).indexOf(String(d.id)).value()
                  Visio.Utils.numberToLetter idx
                else
                  _.find self.activeData, (a, i) -> a.id == d.id
                  Visio.Utils.numberToLetter self.activeData.indexOf(a)
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
          pointContainer = @g.select(".#{self.containerClass}.id-#{d.point.refId()}")
          $(pointContainer.node()).tipsy('show')

          pointContainer.moveToFront()
          pointContainer.classed 'focus', true
        ).on('mouseout', (d) =>
          pointContainer = @g.select(".#{self.containerClass}.id-#{d.point.refId()}")
          pointContainer.classed 'focus', false
          $(pointContainer.node()).tipsy('hide')

        ).on('click', (d, i) =>
          $.publish "active.#{@figureId()}", [d.point, i]

          d3.select(@el).selectAll(".#{self.containerClass}").classed 'selected', false


          # Clicked the same point so deactivate
          if @selectedDatum.get('d')?.id == d.point.id
            @selectedDatum.set 'd', null
          else
            @selectedDatum.set 'd', d.point

            d3.select(@el).select(".#{self.containerClass}.id-#{@selectedDatum.get('d').id}").classed 'selected', true unless @isExport

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

    @renderLegend()
    @$el.find(".#{@containerClass}").tipsy()

    @tipsyHeaderBtns()
    @


  filterFn: (d) =>
    d[@algorithm](Visio.manager.year(), @filters) && d.selectedAchievement(Visio.manager.year(), @filters).result >= 0

  filtered: (collection) => _.chain(collection.models).filter(@filterFn).value()

  polygon: (d) ->
    return "M0 0" unless d? and d.length
    "M" + d.join("L") + "Z"

  select: (e, d, i) =>
    super d,i

    pointContainer = @g.select(".#{@containerClass}.id-#{d.refId()}")
    console.warn 'Selected element is empty' if pointContainer.empty()
    isActive = pointContainer.classed 'active'
    pointContainer.classed 'active', not isActive

    @renderSvgLabels()

  isSelected: (id) =>
    _.chain(@activeData.pluck('id')).map(String).include("#{id}").value()

  isQueried: (d) =>
    !_.isEmpty(@query) and d.toString().toLowerCase().indexOf(@query.toLowerCase()) != -1

  xAxisLabel: ->
    title = @algorithmToHuman()
    return @templateLabel { title: title, subtitles: ['in US Dollars'] }

  algorithmToHuman: ->
    if @algorithm == 'selectedBudget'
      title = 'Budget'
    else if @algorithm == 'selectedBudgetPerBeneficiary'
      title = 'Budget Per Beneficiary'
    else
      title = 'Expenditure Rate (%)'

  graphLabels: =>
    self = @

    @g.selectAll(".#{@containerClass} .graph-label").remove()

    graphLabels = @g.selectAll('.graph-label').data @activeData.models
    graphLabels.enter().append('text')
      .attr('class', 'label graph-label')
      .attr('x', (m) =>
        d = m.get('d')
        self.x(d[self.algorithm](Visio.manager.year(), self.filters)))
      .attr('y', (m) =>
        d = m.get('d')
        self.y(d.selectedAchievement(Visio.manager.year(), self.filters).result))
      .attr('dy', '.3em')
      .text (m, i) =>
        self.selectableLabel m, i


  yAxisLabel: ->

    achievement_type = Visio.Utils.humanMetric Visio.manager.get 'achievement_type'
    return @templateLabel {
        title: 'Achievement',
        subtitles: ['% of Progress', "towards #{achievement_type}"]
      }
