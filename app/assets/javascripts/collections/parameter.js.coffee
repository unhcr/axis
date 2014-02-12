class Visio.Collections.Parameter extends Visio.Collections.Syncable

  model: Visio.Models.Parameter

  comparator: (a, b) ->
    aName = a.toString()
    bName = b.toString()
    return -1 if aName < bName
    return 1 if aName > bName
    return 0 if aName == bName

  search: (query) ->
    $.get("#{@url}/search", { query: query })

  strategyIndicatorData: (strategy, isAnyYear = false, filters = null) ->
    args = arguments
    data = new Visio.Collections.IndicatorDatum()
    @each (model) ->
      data.add model.strategyIndicatorData.apply(model, args).models, silent: true
    data

  strategyBudgetData: (strategy, isAnyYear = false, filters = null) ->
    args = arguments
    data = new Visio.Collections.Budget()
    @each (model) ->
      data.add model.strategyBudgetData.apply(model, args).models, silent: true
    data

  strategyExpenditureData: (strategy, isAnyYear = false, filters = null) ->
    args = arguments
    data = new Visio.Collections.Expenditure()
    @each (model) ->
      data.add model.strategyExpenditureData.apply(model, args).models, silent: true
    data

  strategySituationAnalysis: ->
    data = @strategyIndicatorData()
    data.situationAnalysis()

  strategyExpenditure: ->
    data = @strategyExpenditureData()
    data.amount()

  strategyBudget: () ->
    data = @strategyBudgetData()
    data.amount()
