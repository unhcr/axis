class Visio.Models.Parameter extends Visio.Models.Syncable

  selectedData: (type, isAnyYear = false) ->
    return new Visio.Collections[type.className](Visio.manager.get(type.plural).filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        return true if hash.plural == Visio.Parameters.STRATEGY_OBJECTIVES.plural

        # Skip indicator if it's a budget
        if type.plural == Visio.Syncables.BUDGETS.plural or type.plural == Visio.Syncables.EXPENDITURES.plural
          return true if hash.plural == Visio.Parameters.INDICATORS.plural

        if isAnyYear and hash == Visio.Parameters.PLANS
          pid = d.get("#{hash.singular}_id")
          id = Visio.manager.get(hash.plural).get(pid).get('operation_id')
        else
          id = d.get("#{hash.singular}_id")


        isSelected = Visio.manager.isSelected(hash.plural, pid || id, isAnyYear)
        parameterId = if isAnyYear then @refId() else @id

        if @name == hash.plural
          return parameterId == id and isSelected
        else if hash.plural == Visio.Parameters.OUTPUTS.plural
          return isSelected or not id?
        else
          return isSelected ))

  selectedIndicatorData: (isAnyYear = false) ->
    @selectedData(Visio.Syncables.INDICATOR_DATA, isAnyYear)

  selectedBudgetData: (isAnyYear = false) ->
    @selectedData(Visio.Syncables.BUDGETS, isAnyYear)

  selectedExpenditureData: (isAnyYear = false) ->
    @selectedData(Visio.Syncables.EXPENDITURES, isAnyYear)

  strategyData: (type, strategy) ->
    strategy or= Visio.manager.strategy()

    return new Visio.Collections[type.className](Visio.manager.get(type.plural).filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        return true if hash.plural == Visio.Parameters.STRATEGY_OBJECTIVES.plural
        # Skip indicator if it's a budget
        if type.plural == Visio.Syncables.BUDGETS.plural or type.plural == Visio.Syncables.EXPENDITURES.plural
          return true if hash.plural == Visio.Parameters.INDICATORS.plural

        id = d.get("#{hash.singular}_id")

        isSelected = strategy.get("#{hash.singular}_ids")[id]

        if @name == hash.plural
          return id == @id && isSelected
        else if hash.plural == Visio.Parameters.OUTPUTS.plural
          # Add null/undefined because budget data can have an undefined output
          return isSelected or not id?
        else
          return isSelected ))

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
