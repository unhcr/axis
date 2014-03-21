# Provides functions implementing dashboard stats for a parameter
class Visio.Views.Dashboard extends Backbone.View

  criticalities: [
    { criticality: Visio.Algorithms.ALGO_RESULTS.success, human: 'Acceptable' }
    { criticality: Visio.Algorithms.ALGO_RESULTS.ok, human: 'Critical' }
    { criticality: Visio.Algorithms.ALGO_RESULTS.fail, human: 'Sub-Stanford' }
    { criticality: Visio.Algorithms.STATUS.missing, human: 'Not-Reported' }
  ]

  thresholds: [
    { threshold: Visio.Algorithms.ALGO_RESULTS.high, human: 'Met Target (Above 80%)' }
    { threshold: Visio.Algorithms.ALGO_RESULTS.medium, human: 'Approaching Target (Above 60%)' }
    { threshold: Visio.Algorithms.ALGO_RESULTS.low, human: 'Below Target (Below 60% of target)' }
    { threshold: Visio.Algorithms.STATUS.missing, human: 'Not-Reported' }
  ]

  keyFigures: [
    { fn: 'indicatorCount', human: 'Indicators', formatter: Visio.Formats.NUMBER },
    { fn: 'budget', human: 'Budget', formatter: Visio.Formats.MONEY },
    { fn: 'expenditure', human: 'Expenditure', formatter: Visio.Formats.MONEY },
    { fn: 'spent', human: 'Spent', formatter: Visio.Formats.PERCENT }
  ]

  barFigureData: [
    {
      fn: 'drawOutputAchievements', figure: Visio.FigureTypes.OASY, title: 'Outputs',
      description: 'Achievement of Target'
    },
    {
      fn: 'drawAchievements', figure: Visio.FigureTypes.PASY, title: 'Impact Indicators',
      description: 'Achievement of Standard'
    },
    {
      fn: 'drawCriticalities', figure: Visio.FigureTypes.ICSY, title: 'Impact Criticality',
      description: 'Achievement of Standard'
    }
  ]

  barConfig:
    width: 60
    height: 40
    orientation: 'left'
    margin:
      top: 2
      bottom: 2
      left: 2
      right: 10

  initialize: (options) ->

    if _.isArray options.filters
      @filters = new Visio.Collections.FigureFilter options.filters
    else if options.filters instanceof Visio.Collections.FigureFilter
      @filters = options.filters
    else
      values = {}
      values[Visio.Scenarios.AOL] = false
      values[Visio.Scenarios.OL] = true
      @filters = new Visio.Collections.FigureFilter(
        [{
          id: 'scenario'
          filterType: 'checkbox'
          values: values
        }] )

    @barFigures = {}
    _.each @barFigureData, (d) =>
      @barFigures[d.figure.name] = new Visio.Figures[d.figure.className] _.extend({}, @barConfig)
    @criticalityFigure = new Visio.Figures.Icsy @criticalityConfig
    @achievementFigure = new Visio.Figures.Pasy @achievementConfig
    @outputAchievementFigure = new Visio.Figures.Oasy @outputAchievementConfig

  labelPrefix: =>
    filter = @filters.get('scenario')
    values = filter.get('values')

    if values[Visio.Scenarios.AOL] and values[Visio.Scenarios.OL]
      label = 'Total'
    else if values[Visio.Scenarios.AOL]
      label = 'AOL'
    else if values[Visio.Scenarios.OL]
      label = 'OL'
    else
      label = 'Zero'

    label
  indicatorCount: =>
    @parameter.strategyIndicatorData().length

  budget: =>
    @parameter.strategyBudget(Visio.manager.year(), @filters)

  expenditure: =>
    @parameter.strategyExpenditure(Visio.manager.year(), @filters)

  spent: =>
    spent = @expenditure() / @budget()

    if isNaN(spent) then 0 else spent

  render: (isRerender) ->
    situationAnalysis = @parameter.strategySituationAnalysis()
    category = if situationAnalysis.total == 0 then 'white' else situationAnalysis.category

    unless isRerender
      @$el.html @template
        parameter: @parameter
        criticalities: @criticalities
        thresholds: @thresholds
        keyFigures: @keyFigures
        barFigureData: @barFigureData
        category: category
        idx: @idx
        labelPrefix: @labelPrefix()
        cid: @cid

      _.each @barFigureData, (d) =>
        @$el.find(".#{d.figure.name}-figure-#{@cid}").html @barFigures[d.figure.name].el

    @drawFigures()
    @


  drawFigures: =>
    @drawKeyFigures()
    @drawCriticalities()
    _.each @barFigureData, (d) =>
      @[d.fn]()

  drawKeyFigures: =>
    _.each @keyFigures, (keyFigure) =>
      $keyFigure = @$el.find(".#{keyFigure.fn}-#{@cid} .number")
      $labelPrefix = @$el.find ".#{keyFigure.fn}-#{@cid}  .label-prefix"
      suffix = $keyFigure.text().match /([kMG%])$/
      from = +$keyFigure.text().replace /[^0-9\.]+/g, ""

      if suffix?
        switch suffix[0]
          when '%' then from /= 100
          when 'k' then from *= 1000
          when 'M' then from *= 1000000
          when 'G' then from *= 1000000000

      to = @[keyFigure.fn]()

      speed = if @isPdf then 1 else Visio.Durations.FAST

      $keyFigure.countTo
        from: from
        to: to
        speed: speed
        formatter: keyFigure.formatter
      if keyFigure.fn is 'budget' or
         keyFigure.fn is 'expenditure' or
         keyFigure.fn is 'spent'

        $labelPrefix.text @labelPrefix()

  drawCriticalities: =>
    result = @parameter.strategySituationAnalysis()
    @barFigures[Visio.FigureTypes.ICSY.name].modelFn new Backbone.Model(result)
    @barFigures[Visio.FigureTypes.ICSY.name].render()

    @$el.find(".#{Visio.FigureTypes.ICSY.name}-type-count-#{@cid}").text result.typeTotal
    @$el.find(".#{Visio.FigureTypes.ICSY.name}-selected-count-#{@cid}").text result.total

  drawAchievements: =>
    filters = new Visio.Collections.FigureFilter [{
        id: 'is_performance'
        filterType: 'radio'
        values: { true: false, false: true }
      }]
    result = @parameter.strategyAchievement Visio.manager.year(), filters
    @barFigures[Visio.FigureTypes.PASY.name].modelFn new Backbone.Model result
    @barFigures[Visio.FigureTypes.PASY.name].render()

    @$el.find(".#{Visio.FigureTypes.PASY.name}-type-count-#{@cid}").text result.typeTotal
    @$el.find(".#{Visio.FigureTypes.PASY.name}-selected-count-#{@cid}").text result.total

  drawOutputAchievements: =>
    filters = new Visio.Collections.FigureFilter [{
        id: 'is_performance'
        filterType: 'radio'
        values: { true: true, false: false }
      }]
    result = @parameter.strategyOutputAchievement Visio.manager.year(), filters
    @barFigures[Visio.FigureTypes.OASY.name].modelFn new Backbone.Model result
    @barFigures[Visio.FigureTypes.OASY.name].render()

    @$el.find(".#{Visio.FigureTypes.OASY.name}-type-count-#{@cid}").text result.typeTotal
    @$el.find(".#{Visio.FigureTypes.OASY.name}-selected-count-#{@cid}").text result.total

  close: ->
    @unbind()
    @remove()
