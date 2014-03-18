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

  strategySituationAnalysis: (isAnyYear = false, filters = null) ->
    data = @strategyIndicatorData(null, isAnyYear, filters)
    data.situationAnalysis()

  strategyOutputAchievement: (isAnyYear = false, filters = null) ->
    data = @strategyIndicatorData(null, isAnyYear, filters)
    data.outputAchievement()

  strategyAchievement: (isAnyYear = false, filters = null) ->
    data = @strategyIndicatorData(null, isAnyYear, filters)
    data.achievement()

  strategyExpenditure: (isAnyYear = false, filters = null) ->
    data = @strategyExpenditureData(null, isAnyYear, filters)
    data.amount()

  strategyBudget: (isAnyYear = false, filters = null) ->
    data = @strategyBudgetData(null, isAnyYear, filters)
    data.amount()

  selectedIndicatorData: (isAnyYear = false, filters = null) ->
    args = arguments
    data = new Visio.Collections.IndicatorDatum()
    @each (model) ->
      data.add model.strategyIndicatorData.apply(model, args).models, silent: true
    data
