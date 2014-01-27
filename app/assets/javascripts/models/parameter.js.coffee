class Visio.Models.Parameter extends Visio.Models.Syncable

  selectedData: (type) ->
    return new Visio.Collections[type.className](Visio.manager.get(type.plural).filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        return true if hash.plural == Visio.Parameters.STRATEGY_OBJECTIVES.plural

        # Skip indicator if it's a budget
        if type.plural == Visio.Syncables.BUDGETS.plural or type.plural == Visio.Syncables.EXPENDITURES.plural
          return true if hash.plural == Visio.Parameters.INDICATORS.plural
        id = d.get("#{hash.singular}_id")

        isSelected = Visio.manager.get('selected')[hash.plural][id]

        if @name == hash.plural
          return @id == id and isSelected
        else if hash.plural == Visio.Parameters.OUTPUTS.plural
          return isSelected or not id?
        else
          return isSelected ))

  selectedIndicatorData: () ->
    @selectedData(Visio.Syncables.INDICATOR_DATA)

  selectedBudgetData: () ->
    @selectedData(Visio.Syncables.BUDGETS)

  selectedExpenditureData: () ->
    @selectedData(Visio.Syncables.EXPENDITURES)

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
    return @get 'cache.strategyExpenditure' if @get('cache.strategyExpenditure')?
    data = @strategyExpenditureData()
    @set 'cache.strategyExpenditure', data.amount()
    @get 'cache.strategyExpenditure'

  strategyBudget: () ->
    return @get 'cache.strategyBudget' if @get('cache.strategyBudget')? and not Visio.manager.get 'bust_cache'
    data = @strategyBudgetData()
    @set 'cache.strategyBudget', data.amount()
    @get 'cache.strategyBudget'

  strategySituationAnalysis: () ->
    if @get('cache.strategySituationAnalysis')? and not Visio.manager.get 'bust_cache'
      return @get 'cache.strategySituationAnalysis'
    data = @strategyIndicatorData()
    @set 'cache.strategySituationAnalysis', data.situationAnalysis()
    @get 'cache.strategySituationAnalysis'

  selectedAchievement: () ->
    if @get('cache.selectedAchievement')? and not Visio.manager.get 'bust_cache'
      return @get 'cache.selectedAchievement'
    data = @selectedIndicatorData()
    @set 'cache.selectedAchievement', data.achievement()
    @get 'cache.selectedAchievement'

  selectedBudget: () ->
    if @get('cache.selectedBudget')? and not Visio.manager.get 'bust_cache'
      return @get 'cache.selectedBudget'
    data = @selectedBudgetData()
    @set 'cache.selectedBudget', data.amount()
    @get 'cache.selectedBudget'

  selectedSituationAnalysis: () ->
    if @get('cache.selectedSituationAnalysis')? and not Visio.manager.get 'bust_cache'
      return @get 'cache.selectedSituationAnalysis'
    data = @selectedIndicatorData()
    @set 'cache.selectedSiutationAnalysis', data.amount()
    @get 'cache.selectedSiutationAnalysis'

  selectedExpenditure: ->
    if @get('cache.selectedExpenditure')? and not Visio.manager.get 'bust_cache'
      return @get 'cache.selectedExpenditure'
    data = @selectedExpenditureData()
    @set 'cache.selectedExpenditure', data.amount()
    @get 'cache.selectedExpenditure'

  refId: ->
    @id

  selectedAmount: ->
    # Either Budget or Expenditure
    @["selected#{Visio.manager.get('amount_type').className}"]()
