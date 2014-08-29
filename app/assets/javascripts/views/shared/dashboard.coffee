# Provides functions implementing dashboard stats for a parameter
class Visio.Views.Dashboard extends Backbone.View

  criticalities: Visio.Algorithms.CRITICALITIES

  thresholds: Visio.Algorithms.THRESHOLDS

  keyFigures: [
    { fn: 'indicatorCount', human: 'Indicators', formatter: Visio.Formats.NUMBER },
    { fn: 'budget', human: 'Budget', formatter: Visio.Formats.MONEY },
    { fn: 'expenditure', human: 'Expenditure', formatter: Visio.Formats.MONEY },
    { fn: 'spent', human: 'Spent', formatter: Visio.Formats.PERCENT }
  ]

  barFigureData: [
    {
      fn: 'drawPerformanceAchievements', figure: Visio.FigureTypes.PASY, title: 'Performance Achievements',
      description: 'Achievement of Target', unit: 'Indicators', short: 'Performance'
    },
    {
      fn: 'drawImpactAchievements', figure: Visio.FigureTypes.IASY, title: 'Impact Achievements',
      description: 'Achievement of Target', unit: 'Indicators', short: 'Impact'
    },
    {
      fn: 'drawCriticalities', figure: Visio.FigureTypes.ICSY, title: 'Impact Criticality',
      description: 'Achievement of Standard', unit: 'Indicators', short: 'Criticality'
    }
  ]

  initialize: (options) ->

    @barConfig = options.barConfig

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
    @parameter.selectedIndicatorData().length

  budget: =>
    @parameter.selectedBudget(Visio.manager.year(), @filters)

  expenditure: =>
    @parameter.selectedExpenditure(Visio.manager.year(), @filters)

  spent: =>
    spent = @expenditure() / @budget()

    if isNaN(spent) then 0 else spent

  render: (isRerender) ->
    situationAnalysis = @parameter.selectedSituationAnalysis()
    category = if situationAnalysis.total == 0 then 'white' else situationAnalysis.category

    unless isRerender
      @$el.html @template
        parameter: @parameter
        criticalities: @criticalities
        thresholds: @thresholds
        keyFigures: @keyFigures
        barFigureData: @barFigureData
        selectedBarFigure: @selectedBarFigure
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

      speed = Visio.Durations.FAST

      if @isPdf
        $keyFigure.text keyFigure.formatter(to)
      else
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
    result = @parameter.selectedSituationAnalysis()
    @barFigures[Visio.FigureTypes.ICSY.name].modelFn new Backbone.Model(result)
    @barFigures[Visio.FigureTypes.ICSY.name].render()

    @$el.find(".#{Visio.FigureTypes.ICSY.name}-type-count-#{@cid}").text result.typeTotal
    @$el.find(".#{Visio.FigureTypes.ICSY.name}-selected-count-#{@cid}").text result.total

  drawImpactAchievements: =>
    result = @parameter.selectedImpactAchievement()
    @barFigures[Visio.FigureTypes.IASY.name].modelFn new Backbone.Model result
    @barFigures[Visio.FigureTypes.IASY.name].render()

    @$el.find(".#{Visio.FigureTypes.IASY.name}-type-count-#{@cid}").text result.typeTotal
    @$el.find(".#{Visio.FigureTypes.IASY.name}-selected-count-#{@cid}").text result.total

  drawPerformanceAchievements: =>
    result = @parameter.selectedPerformanceAchievement()
    console.log result
    @barFigures[Visio.FigureTypes.PASY.name].modelFn new Backbone.Model result
    @barFigures[Visio.FigureTypes.PASY.name].render()

    @$el.find(".#{Visio.FigureTypes.PASY.name}-type-count-#{@cid}").text result.typeTotal
    @$el.find(".#{Visio.FigureTypes.PASY.name}-selected-count-#{@cid}").text result.total

  close: ->
    @unbind()
    @remove()
