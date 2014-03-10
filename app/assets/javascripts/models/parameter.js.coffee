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

  strategyExpenditure: (isAnyYear = false, filters = null) ->
    data = @strategyExpenditureData(null, isAnyYear, filters)
    data.amount()

  strategyBudget: (isAnyYear = false, filters = null) ->
    data = @strategyBudgetData(null, isAnyYear, filters)
    data.amount()

  strategySituationAnalysis: () ->
    data = @strategyIndicatorData()
    data.situationAnalysis()

  selectedAchievement: (isAnyYear = false, filters = null) ->
    data = @selectedIndicatorData(isAnyYear, filters)
    data.achievement()

  selectedBudget: (isAnyYear = false, filters = null) ->
    data = @selectedBudgetData(isAnyYear, filters)
    data.amount()

  selectedSituationAnalysis: (isAnyYear = false, filters = null) ->
    data = @selectedIndicatorData(isAnyYear, filters)
    data.situationAnalysis()

  selectedExpenditure: (isAnyYear = false, filters = null) ->
    data = @selectedExpenditureData(isAnyYear, filters)
    data.amount()

  refId: ->
    @id

  search: (query) ->
    $.get("#{@url}/search", { query: query })

  selectedAmount: (isAnyYear = false, filters = null) ->
    # Either Budget or Expenditure
    @["selected#{Visio.manager.get('amount_type').className}"](isAnyYear, filters)

  highlight: ->
    return @get('highlight').name[0] if @get('highlight')
