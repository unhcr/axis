# Provides functions implementing dashboard stats for a parameter
class Visio.Views.Dashboard extends Backbone.View

  criticalities: [
    Visio.Algorithms.ALGO_RESULTS.success,
    Visio.Algorithms.ALGO_RESULTS.ok,
    Visio.Algorithms.ALGO_RESULTS.fail,
    Visio.Algorithms.STATUS.missing,
  ]

  keyFigures: [
    { fn: 'indicatorCount', human: 'Indicators', formatter: Visio.Formats.NUMBER },
    { fn: 'budget', human: 'Budget', formatter: Visio.Formats.MONEY },
    { fn: 'expenditure', human: 'Expenditure', formatter: Visio.Formats.MONEY },
    { fn: 'spent', human: 'Spent', formatter: Visio.Formats.PERCENT }
  ]

  criticalityConfig:
    width: 40
    height: 40
    number: 0
    percent: 0
    margin:
      top: 2
      bottom: 2
      left: 2
      right: 2

  initialize: (options) ->
    console.log options.filters
    if _.isArray options.filters
      @filters = new Visio.Collections.FigureFilter options.filters
    else if options.filters instanceof Visio.Collections.FigureFilter
      @filters = options.filters
    else
      @filters = new Visio.Collections.FigureFilter(
        [{
          id: 'scenario'
          filterType: 'checkbox'
          values: _.object(_.values(Visio.Scenarios), _.values(Visio.Scenarios).map(-> true))
        }] )

    @criticalityFigures = []

    _.each @criticalities, (criticality) =>
      @criticalityFigures.push
        figure: new Visio.Figures.Circle(_.extend({}, @criticalityConfig))
        criticality: criticality

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
    @parameter.strategyBudget(false, @filters)

  expenditure: =>
    @parameter.strategyExpenditure(false, @filters)

  spent: =>
    (@expenditure() / @budget())

  render: (isRerender) ->
    situationAnalysis = @parameter.strategySituationAnalysis()
    category = if situationAnalysis.total == 0 then 'white' else situationAnalysis.category

    unless isRerender
      @$el.html @template(
        parameter: @parameter
        criticalities: @criticalities
        keyFigures: @keyFigures
        category: category
        idx: @idx
        labelPrefix: @labelPrefix()
      )

      _.each @criticalityFigures, (figure) =>
        @$el.find(".#{figure.criticality}-criticality").html figure.figure.el


    @drawFigures()
    @


  drawFigures: =>
    @drawCriticalities()
    @drawKeyFigures()


  drawKeyFigures: =>
    _.each @keyFigures, (keyFigure) =>
      $keyFigure = @$el.find(".#{keyFigure.fn} .number:last")
      $labelPrefix = @$el.find ".#{keyFigure.fn} .label-prefix:last"
      from = +$keyFigure.text().replace(/[^0-9\.]+/g,"")
      to = @[keyFigure.fn]()

      $keyFigure.countTo
        from: from
        to: to
        speed: Visio.Durations.FAST
        formatter: keyFigure.formatter
      if keyFigure.fn is 'budget' or
         keyFigure.fn is 'expenditure' or
         keyFigure.fn is 'spent'

        $labelPrefix.text @labelPrefix()

  drawCriticalities: =>
    result = @parameter.strategySituationAnalysis()
    _.each @criticalityFigures, (figure) =>
      percent = (result.counts[figure.criticality] / result.total) || 0
      figure.figure
        .numberFn(result.counts[figure.criticality])
        .percentFn(percent)
        .render()

      @$el.find(".#{figure.criticality}-count:last").text result.counts[figure.criticality]

    @$el.find('.total-count:last').text result.total

  close: ->
    @unbind()
    @remove()
