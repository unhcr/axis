class Visio.Models.Parameter extends Visio.Models.Syncable

  data: (type, idHash, isAnyYear = false) ->
    condition = {}
    condition["#{@name.singular}_id"] = @id
    data = Visio.manager.get(type.plural).where(condition)

    data = _.filter data, (d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        return true if @name.plural == hash.plural

        # Must be current year if we are specifying year
        return false if not isAnyYear and Visio.manager.year() != d.get('year')


        # Skip indicator if it's a budget
        if type.plural == Visio.Syncables.BUDGETS.plural or
           type.plural == Visio.Syncables.EXPENDITURES.plural
          return true if hash.plural == Visio.Parameters.INDICATORS.plural

        id = d.get("#{hash.singular}_id")

        # If output_id is missing that's ok
        return true if not id? and hash = Visio.Parameters.OUTPUTS

        idHash[hash.plural][id]

    return new Visio.Collections[type.className](data)

  selectedIndicatorData: (isAnyYear = false) ->
    @selectedData(Visio.Syncables.INDICATOR_DATA, isAnyYear)

  selectedBudgetData: (isAnyYear = false) ->
    @selectedData(Visio.Syncables.BUDGETS, isAnyYear)

  selectedExpenditureData: (isAnyYear = false) ->
    @selectedData(Visio.Syncables.EXPENDITURES, isAnyYear)

  selectedData: (type, isAnyYear = false) ->
    @data type, Visio.manager.get('selected'), isAnyYear

  strategyData: (type, strategy, isAnyYear = false) ->
    strategy or= Visio.manager.strategy()
    idHash = {}

    _.each _.values(Visio.Parameters), (hash) ->
      idHash[hash.plural] = strategy.get("#{hash.singular}_ids")

    @data type, idHash, isAnyYear


  strategyIndicatorData: (strategy) ->
    @strategyData(Visio.Syncables.INDICATOR_DATA, strategy)

  strategyBudgetData: (strategy) ->
    @strategyData(Visio.Syncables.BUDGETS, strategy)

  strategyExpenditureData: (strategy) ->
    @strategyData(Visio.Syncables.EXPENDITURES, strategy)

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

  selectedAchievement: () ->
    if @useCache 'selectedAchievement'
      return @get 'cache.selectedAchievement'
    data = @selectedIndicatorData()
    @set 'cache.selectedAchievement', data.achievement()
    @get 'cache.selectedAchievement'

  selectedBudget: () ->
    if @useCache 'selectedBudget'
      return @get 'cache.selectedBudget'
    data = @selectedBudgetData()
    @set 'cache.selectedBudget', data.amount()
    @get 'cache.selectedBudget'

  selectedSituationAnalysis: () ->
    if @useCache 'selectedSituationAnalysis'
      return @get 'cache.selectedSituationAnalysis'
    data = @selectedIndicatorData()
    @set 'cache.selectedSituationAnalysis', data.situationAnalysis()
    @get 'cache.selectedSituationAnalysis'

  selectedExpenditure: ->
    if @useCache 'selectedExpenditure'
      return @get 'cache.selectedExpenditure'
    data = @selectedExpenditureData()
    @set 'cache.selectedExpenditure', data.amount()
    @get 'cache.selectedExpenditure'

  useCache: (key) ->
    @get("cache.#{key}")? and Visio.manager.get('use_cache') and not Visio.manager.get 'bust_cache'

  refId: ->
    @id

  selectedAmount: ->
    # Either Budget or Expenditure
    @["selected#{Visio.manager.get('amount_type').className}"]()
