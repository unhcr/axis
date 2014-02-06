class Visio.Models.Parameter extends Visio.Models.Syncable

  data: (type, idHash, isAnyYear = false, filters) ->


    # Return empty collection since indicators do not have budgets or expenditures
    if (type.plural == Visio.Syncables.BUDGETS.plural or
       type.plural == Visio.Syncables.EXPENDITURES.plural) and
       @name == Visio.Parameters.INDICATORS
      return new Visio.Collections[type.className]()

    if @name == Visio.Parameters.STRATEGY_OBJECTIVES
      data = Visio.manager.get(type.plural).filter((d) => _.include d.get("#{@name.singular}_ids"), @id)
    else
      condition = {}
      condition["#{@name.singular}_id"] = @id
      data = Visio.manager.get(type.plural).where(condition)

    data = _.filter data, (d) => not filters? or not filters.isFiltered(d)

    data = _.filter data, (d) =>
      return _.every _.values(Visio.Parameters), (hash) =>

        return true if @name.plural == hash.plural

        # Must be current year if we are specifying year
        return false if not isAnyYear and Visio.manager.year() != d.get('year')

        # Skip indicator if it's a budget
        if (type.plural == Visio.Syncables.BUDGETS.plural or
           type.plural == Visio.Syncables.EXPENDITURES.plural) and
           hash.plural == Visio.Parameters.INDICATORS.plural
          return true


        # One of strategy objective ids must be selected
        if hash == Visio.Parameters.STRATEGY_OBJECTIVES
          ids = d.get("#{hash.singular}_ids")
          return _.any ids, (id) -> idHash[hash.plural][id]


        id = d.get("#{hash.singular}_id")

        # If output_id is missing that's ok
        return true if not id? and hash = Visio.Parameters.OUTPUTS


        idHash[hash.plural][id]

    return new Visio.Collections[type.className](data)

  selectedIndicatorData: (isAnyYear = false, filters = null) ->
    @selectedData(Visio.Syncables.INDICATOR_DATA, isAnyYear, filters)

  selectedBudgetData: (isAnyYear = false, filters = null) ->
    @selectedData(Visio.Syncables.BUDGETS, isAnyYear, filters)

  selectedExpenditureData: (isAnyYear = false, filters = null) ->
    @selectedData(Visio.Syncables.EXPENDITURES, isAnyYear, filters)

  selectedData: (type, isAnyYear = false, filters = null) ->
    @data type, Visio.manager.get('selected'), isAnyYear, filters

  strategyData: (type, strategy, isAnyYear = false, filters = null) ->
    strategy or= Visio.manager.strategy()
    idHash = {}

    _.each _.values(Visio.Parameters), (hash) ->
      idHash[hash.plural] = strategy.get("#{hash.singular}_ids")

    @data type, idHash, isAnyYear, filters


  strategyIndicatorData: (strategy, isAnyYear = false, filters = null) ->
    @strategyData(Visio.Syncables.INDICATOR_DATA, strategy, isAnyYear, filters)

  strategyBudgetData: (strategy, isAnyYear = false, filters = null) ->
    @strategyData(Visio.Syncables.BUDGETS, strategy, isAnyYear, filters)

  strategyExpenditureData: (strategy, isAnyYear = false, filters = null) ->
    @strategyData(Visio.Syncables.EXPENDITURES, strategy, isAnyYear, filters)

  strategyExpenditure: ->
    return @get 'cache.strategyExpenditure' if @useCache 'strategyExpenditure'
    data = @strategyExpenditureData()
    @set 'cache.strategyExpenditure', data.amount()
    @get 'cache.strategyExpenditure'

  strategyBudget: () ->
    return @get 'cache.strategyBudget' if @useCache 'strategyBudget'
    data = @strategyBudgetData()
    @set 'cache.strategyBudget', data.amount()
    @get 'cache.strategyBudget'

  strategySituationAnalysis: () ->
    if @useCache 'strategySituationAnalysis'
      return @get 'cache.strategySituationAnalysis'
    data = @strategyIndicatorData()
    @set 'cache.strategySituationAnalysis', data.situationAnalysis()
    @get 'cache.strategySituationAnalysis'

  selectedAchievement: (isAnyYear = false, filters = null) ->
    if @useCache 'selectedAchievement'
      return @get 'cache.selectedAchievement'
    data = @selectedIndicatorData(isAnyYear = false, filters = null)
    @set 'cache.selectedAchievement', data.achievement()
    @get 'cache.selectedAchievement'

  selectedBudget: (isAnyYear = false, filters = null) ->
    if @useCache 'selectedBudget'
      return @get 'cache.selectedBudget'
    data = @selectedBudgetData(isAnyYear, filters)
    @set 'cache.selectedBudget', data.amount()
    @get 'cache.selectedBudget'

  selectedSituationAnalysis: (isAnyYear = false, filters = null) ->
    if @useCache 'selectedSituationAnalysis'
      return @get 'cache.selectedSituationAnalysis'
    data = @selectedIndicatorData(isAnyYear, filters)
    @set 'cache.selectedSituationAnalysis', data.situationAnalysis()
    @get 'cache.selectedSituationAnalysis'

  selectedExpenditure: (isAnyYear = false, filters = null) ->
    if @useCache 'selectedExpenditure'
      return @get 'cache.selectedExpenditure'
    data = @selectedExpenditureData(isAnyYear, filters)
    @set 'cache.selectedExpenditure', data.amount()
    @get 'cache.selectedExpenditure'

  useCache: (key) ->
    @get("cache.#{key}")? and Visio.manager.get('use_cache') and not Visio.manager.get 'bust_cache'

  refId: ->
    @id

  selectedAmount: (isAnyYear = false, filters = null) ->
    # Either Budget or Expenditure
    @["selected#{Visio.manager.get('amount_type').className}"](isAnyYear, filters)
