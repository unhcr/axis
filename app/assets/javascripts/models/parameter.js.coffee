class Visio.Models.Parameter extends Visio.Models.Syncable

  # @param: year - Allows for any specified year or false which will use all years. If undefined, will fall
  # back to current year
  data: (type, idHash, year, filters) ->
    year = Visio.manager.year() unless year?


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
        return false if year != Visio.Constants.ANY_YEAR and year != d.get('year')

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

  selectedIndicatorData: (year, filters = null) ->
    @selectedData(Visio.Syncables.INDICATOR_DATA, year, filters)

  selectedBudgetData: (year, filters = null) ->
    @selectedData(Visio.Syncables.BUDGETS, year, filters)

  selectedExpenditureData: (year, filters = null) ->
    @selectedData(Visio.Syncables.EXPENDITURES, year, filters)

  selectedData: (type, year, filters = null) ->
    @data type, Visio.manager.get('selected'), year, filters

  strategyData: (type, strategy, year, filters = null) ->
    strategy or= Visio.manager.strategy()
    idHash = {}

    _.each _.values(Visio.Parameters), (hash) ->
      idHash[hash.plural] = strategy.get("#{hash.singular}_ids")

    @data type, idHash, year, filters


  strategyIndicatorData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.INDICATOR_DATA, strategy, year, filters)

  strategyBudgetData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.BUDGETS, strategy, year, filters)

  strategyExpenditureData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.EXPENDITURES, strategy, year, filters)

  strategyExpenditure: (year, filters = null) ->
    data = @strategyExpenditureData(null, year, filters)
    data.amount()

  strategyBudget: (year, filters = null) ->
    data = @strategyBudgetData(null, year, filters)
    data.amount()

  strategySituationAnalysis: () ->
    data = @strategyIndicatorData()
    data.situationAnalysis()

  strategyAchievement: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.achievement()

  strategyOutputAchievement: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.outputAchievement()

  selectedAchievement: (year, filters = null) ->
    data = @selectedIndicatorData(year, filters)
    data.achievement()

  selectedBudget: (year, filters = null) ->
    data = @selectedBudgetData(year, filters)
    data.amount()

  selectedSituationAnalysis: (year, filters = null) ->
    data = @selectedIndicatorData(year, filters)
    data.situationAnalysis()

  selectedExpenditure: (year, filters = null) ->
    data = @selectedExpenditureData(year, filters)
    data.amount()

  refId: ->
    @id

  search: (query) ->
    $.get("#{@url}/search", { query: query })

  selectedAmount: (year, filters = null) ->
    # Either Budget or Expenditure
    @["selected#{Visio.manager.get('amount_type').className}"](year, filters)

  highlight: ->
    return @get('highlight').name[0] if @get('highlight')
