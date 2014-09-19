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

  strategyIndicatorData: (strategy, year, filters = null) ->
    args = arguments
    data = new Visio.Collections.IndicatorDatum()
    @each (model) ->
      data.add model.strategyIndicatorData.apply(model, args).models, silent: true
    data

  strategyBudgetData: (strategy, year, filters = null) ->
    args = arguments
    data = new Visio.Collections.Budget()
    @each (model) ->
      data.add model.strategyBudgetData.apply(model, args).models, silent: true
    data

  strategyExpenditureData: (strategy, year, filters = null) ->
    args = arguments
    data = new Visio.Collections.Expenditure()
    @each (model) ->
      data.add model.strategyExpenditureData.apply(model, args).models, silent: true
    data

  strategySituationAnalysis: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.situationAnalysis()

  strategyOutputAchievement: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.outputAchievement()

  strategyAchievement: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.achievement()

  strategyExpenditure: (year, filters = null) ->
    data = @strategyExpenditureData(null, year, filters)
    data.amount()

  strategyBudget: (year, filters = null) ->
    data = @strategyBudgetData(null, year, filters)
    data.amount()

  selectedSituationAnalysis: (year, filters = null) ->
    data = @selectedIndicatorData year, filters
    data.situationAnalysis()

  selectedOutputAchievement: (year, filters = null) ->
    data = @selectedIndicatorData year, filters
    data.outputAchievement()

  selectedPerformanceAchievement: (year, filters = null) ->
    filters or= new Visio.Collections.FigureFilter()
    filters.add { id: 'is_performance', filterType: 'radio', values: { true: true, false: false } },
        { merge: true }

    console.log filters.toJSON()

    @selectedAchievement year, filters

  selectedImpactAchievement: (year, filters = null) ->
    filters or= new Visio.Collections.FigureFilter()
    filters.add { id: 'is_performance', filterType: 'radio', values: { true: false, false: true } },
        { merge: true }

    @selectedAchievement year, filters

  # If it's a number indicator sum all data associated
  selectedIndicatorSum: (year, filters = null) ->
    console.warn 'Warning, using outside of indicator dashboard' unless Visio.manager.get('indicator')

    null unless Visio.manager.get('indicator')?.isNumber()

    data = @selectedIndicatorData year, filters
    data.sum()

  selectedAchievement: (year, filters = null) ->
    data = @selectedIndicatorData year, filters
    data.achievement()

  selectedBudget: (year, filters = null) ->
    data = @selectedBudgetData(year, filters)
    data.amount()

  selectedExpenditure: (year, filters = null) ->
    data = @selectedExpenditureData(year, filters)
    data.amount()

  selectedIndicatorData: (year, filters = null) ->
    args = arguments
    data = new Visio.Collections.IndicatorDatum()
    @each (model) ->
      data.add model.selectedIndicatorData.apply(model, args).models, silent: true
    data

  selectedBudgetData: (year, filters = null) ->
    args = arguments
    data = new Visio.Collections.Budget()
    @each (model) ->
      data.add model.selectedBudgetData.apply(model, args).models, silent: true
    data

  selectedExpenditureData: (year, filters = null) ->
    args = arguments
    data = new Visio.Collections.Expenditure()
    @each (model) ->
      data.add model.selectedExpenditureData.apply(model, args).models, silent: true
    data
