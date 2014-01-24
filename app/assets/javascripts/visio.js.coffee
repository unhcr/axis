window.Visio =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Utils: {}
  Graphs: {}
  AchievementTypes:
    TARGET: 'comp_target'
    STANDARD: 'standard'
  Scenarios:
    OL: 'Operating Level'
    AOL: 'Above Operating Level'
  Budgets:
    ADMIN: 'ADMIN'
    PARTNER: 'PARTNER'
    PROJECT: 'PROJECT'
    STAFF: 'STAFF'
  Durations:
    VERY_FAST: 100
    FAST: 500
    MEDIUM: 1000
    SLOW: 2000
  Formats:
    SI: d3.format('0.3s')
    PERCENT: d3.format(".0%")
  Constants:
    DB_NAME: 'visio'
    SEPARATOR: '___'
  Stores:
    MAP: 'map'
    SYNC: 'sync_date'
  Parameters:
    PLANS:
      singular: 'plan'
      plural: 'plans'
      className: 'Plan'
      human: 'Operations'
    PPGS:
      singular: 'ppg'
      plural: 'ppgs'
      className: 'Ppg'
      human: 'PPGs'
    GOALS:
      singular: 'goal'
      plural: 'goals'
      className: 'Goal'
      human: 'Goals'
    INDICATORS:
      singular: 'indicator'
      plural: 'indicators'
      className: 'Indicator'
      human: 'Indicators'
    OUTPUTS:
      singular: 'output'
      plural: 'outputs'
      className: 'Output'
      human: 'Outputs'
    PROBLEM_OBJECTIVES:
      singular: 'problem_objective'
      plural: 'problem_objectives'
      className: 'ProblemObjective'
      human: 'Objectives'
    STRATEGY_OBJECTIVES:
      singular: 'strategy_objective'
      plural: 'strategy_objectives'
      className: 'StrategyObjective'
      human: 'Strategy Objective'

  SkippedParameters:
    RIGHTS_GROUPS:
      singular: 'rights_group'
      plural: 'rights_groups'
      className: 'RightsGroup'
      human: 'Rights Groups'

  Syncables:
    INDICATOR_DATA:
      singular: 'indicator_datum'
      plural: 'indicator_data'
      className: 'IndicatorDatum'
      human: 'Indicator Datum'
    BUDGETS:
      singular: 'budget'
      plural: 'budgets'
      className: 'Budget'
      human: 'Budget'
    EXPENDITURES:
      singular: 'expenditure'
      plural: 'expenditures'
      className: 'Expenditure'
      human: 'Expenditure'
    OPERATIONS:
      singular: 'operation'
      plural: 'operations'
      className: 'Operation'
      human: 'Operation'
  Algorithms:
    SUCCESS_THRESHOLD: 0.66
    OK_THRESHOLD: 0.33
    HIGH_THRESHOLD: 0.8
    MEDIUM_THRESHOLD: 0.6
    ALGO_RESULTS:
      success: 'success'
      ok: 'ok'
      fail: 'fail'
      missing: 'missing'
      high: 'high'
      medium: 'medium'
      low: 'low'

    REPORTED_VALUES:
      myr: 'myr'
      yer: 'yer'
      baseline: 'baseline'

    GOAL_TYPES:
      standard: 'standard'
      target: 'comp_target'

Visio.ProgressTypes =
  BASELINE_MYR:
    "#{Visio.Algorithms.REPORTED_VALUES.baseline}#{Visio.Constants.SEPARATOR}#{Visio.Algorithms.REPORTED_VALUES.myr}"
  BASELINE_YER:
    "#{Visio.Algorithms.REPORTED_VALUES.baseline}#{Visio.Constants.SEPARATOR}#{Visio.Algorithms.REPORTED_VALUES.yer}"
  MYR_YER:
    "#{Visio.Algorithms.REPORTED_VALUES.myr}#{Visio.Constants.SEPARATOR}#{Visio.Algorithms.REPORTED_VALUES.yer}"

Visio.AggregationTypes = [
    Visio.Parameters.PLANS,
    Visio.Parameters.PPGS,
    Visio.Parameters.GOALS,
    Visio.Parameters.OUTPUTS,
    Visio.Parameters.PROBLEM_OBJECTIVES,
    Visio.Parameters.STRATEGY_OBJECTIVES,
  ]

Visio.Schema =
    stores: []

_.each _.values(Visio.Parameters), (hash) ->
  Visio.Schema.stores.push {
    name: hash.plural + '_store'
    keyPath: 'id'
    autoIncrement: false
  }

_.each _.values(Visio.Syncables), (hash) ->
  Visio.Schema.stores.push {
    name: hash.plural + '_store'
    keyPath: 'id'
    autoIncrement: false
  }

Visio.Schema.stores.push {
    name: Visio.Stores.MAP
    autoIncrement: false
  }

Visio.Schema.stores.push {
    name: Visio.Stores.SYNC
    autoIncrement: false
  }
