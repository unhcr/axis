# Provides functions implementing dashboard stats for a parameter
class Visio.Views.Dashboard extends Visio.Views.ExportableView

  criticalities: [
    Visio.Algorithms.ALGO_RESULTS.success,
    Visio.Algorithms.ALGO_RESULTS.ok,
    Visio.Algorithms.ALGO_RESULTS.fail,
    Visio.Algorithms.STATUS.missing,
  ]

  keyFigures: [
    { fn: 'indicatorCount', human: 'Total Indicators', formatter: Visio.Formats.NUMBER },
    { fn: 'budget', human: 'Total Budget', formatter: Visio.Formats.MONEY },
    { fn: 'expenditure', human: 'Total Expenditure', formatter: Visio.Formats.MONEY },
    { fn: 'spent', human: 'Total Spent', formatter: Visio.Formats.PERCENT }
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

  initialize: ->
    @criticalityFigures = []

    _.each @criticalities, (criticality) =>
      @criticalityFigures.push
        figure: new Visio.Figures.Circle(_.extend({}, @criticalityConfig))
        criticality: criticality

  indicatorCount: =>
    @parameter.strategyIndicatorData().length

  budget: =>
    @parameter.strategyBudget()

  expenditure: =>
    @parameter.strategyExpenditure()

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
      from = +$keyFigure.text().replace(/[^0-9\.]+/g,"")
      to = @[keyFigure.fn]()

      $keyFigure.countTo
        from: from
        to: to
        speed: Visio.Durations.FAST
        formatter: keyFigure.formatter

  drawCriticalities: =>
    result = @parameter.strategySituationAnalysis()
    _.each @criticalityFigures, (figure) =>
      percent = (result.counts[figure.criticality] / result.total) || 0
      figure.figure
        .numberFn(result.counts[figure.criticality])
        .percentFn(percent)
        .render()

      @$el.find(".#{figure.criticality}-count:last").text result.counts[figure.criticality]

  close: ->
    @unbind()
    @remove()
