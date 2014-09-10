window.Visio =
  Models: {}
  Collections: {}
  Views: {}
  Mixins: {}
  Routers: {}
  Utils: {}
  Figures: {}
  Legends: {}
  Labels: {}
  FigureTypes:
    MAP:
      className: 'Map'
      human: 'Map'
      name: 'map'
    # Indicator Criticality Multiple Year
    ICMY:
      className: 'Icmy'
      human: 'Impact Criticality vs Time'
      name: 'icmy'
    # Indicator Criticality Single Year
    ICSY:
      className: 'Icsy'
      human: 'Impact Criticality single year'
      name: 'icsy'
      description: 'Achievement of Standard'
    # Performance Achievement Single Year
    IASY:
      className: 'Pasy'
      human: 'Impact Achievement single year'
      name: 'iasy'
      description: 'Achievement of Target'
    # Performance Achievement Single Year
    PASY:
      className: 'Pasy'
      human: 'Performance Achievement single year'
      name: 'pasy'
      description: 'Achievement of Target'
    # Output Achievement Single Year
    OASY:
      className: 'Oasy'
      human: 'Output Achievement single year'
      name: 'oasy'
      description: 'Achievement of Target'
    SPARK:
      className: 'Spark'
      human: 'Spark'
      name: 'spark'
    CIRCLE:
      className: 'Circle'
      human: 'Circle'
      name: 'circle'
    OVERVIEW:
      className: 'SnapshotView'
      human: 'Overview'
      name: 'snapshot'
    # Achievement Budget Single Year
    ABSY:
      className: 'Absy'
      human: 'Achievement vs Budget'
      name: 'absy'
    # Achievement Budget Single Year
    BSY:
      className: 'Bsy'
      human: 'Budget Single Year'
      name: 'bsy'
    # Budget Multiple Year
    BMY:
      className: 'Bmy'
      human: 'Budget vs Time'
      name: 'bmy'
    # Budget Multiple Year Summary
    BMY_SUMMARY:
      className: 'BmySummary'
      human: 'Budget vs Time'
      name: 'bmys'
    # Indicators Single Year
    ISY:
      className: 'Isy'
      human: 'Indicators'
      name: 'isy'
    AXIS:
      className: 'Axis'
      human: ''
      name: 'axis'
  Scenarios:
    OL: 'Operating Level'
    AOL: 'Above Operating Level'
  Budgets:
    ADMIN: 'ADMIN'
    PARTNER: 'PARTNER'
    PROJECT: 'PROJECT'
    STAFF: 'STAFF'
  Pillars:
    LYPK: 'Refugee'
    LYPM: 'Internally Displaced'
    LYPN: 'Returnee'
    LYPJ: 'All populations of conern'
    LYPL: 'Stateless'
  IndicatorTypes:
    PERCENTAGE: 'PERCENTAGE'
    YESNOPARTIAL: 'YESNOPARTIAL'
    NCNUMBER: 'NCNUMBER'
    AVERAGE: 'AVERAGE'
    NUMBEROF: 'NUMBEROF'
  Durations:
    VERY_FAST: 100
    FAST: 500
    MEDIUM: 1000
    SLOW: 2000
  Formats:
    MONEY: d3.format('$0.3s')
    LONG_MONEY: d3.format('$,f')
    SI: d3.format('0.3s')
    SI_SIMPLE: d3.format('s')
    PERCENT: d3.format(".0%")
    PERCENT_NOSIGN: (d) -> (d * 100).toFixed()
    COMMA: d3.format(',')
    NUMBER: d3.format('d')
    LONG_NUMBER: d3.format(',f')
  Constants:
    FILTERS_WIDTH: 412
    LEGEND_WIDTH: 300
    ANY_YEAR: 'ANY_YEAR'
    ANY_STRATEGY_OBJECTIVE: 'ANY_STRATEGY_OBJECTIVE'
    DB_NAME: 'visio'
    SEPARATOR: '___'
    ALPHABET: 'abcdefghijklmnopqrstuvwxyz'
    CMS:
      TEXTAREA_MAXLEN: 900

  Texts:
    STRATEGY_DESC: 'Global or Regional Strategies are defined by focal points in HQ or RO. The visualizations in the dashboads'

  Stores:
    MAP: 'map'
    SYNC: 'sync_date'
  Parameters:
    OPERATIONS:
      singular: 'operation'
      plural: 'operations'
      name: 'operations'
      className: 'Operation'
      human: 'Operation'
    PPGS:
      singular: 'ppg'
      plural: 'ppgs'
      name: 'ppgs'
      className: 'Ppg'
      human: 'PPG'
    GOALS:
      singular: 'goal'
      plural: 'goals'
      name: 'goals'
      className: 'Goal'
      human: 'Goal'
    INDICATORS:
      singular: 'indicator'
      plural: 'indicators'
      name: 'indicators'
      className: 'Indicator'
      human: 'Indicator'
    OUTPUTS:
      singular: 'output'
      plural: 'outputs'
      name: 'outputs'
      className: 'Output'
      human: 'Output'
    PROBLEM_OBJECTIVES:
      singular: 'problem_objective'
      plural: 'problem_objectives'
      name: 'problem_objectives'
      className: 'ProblemObjective'
      human: 'Objective'
    STRATEGY_OBJECTIVES:
      singular: 'strategy_objective'
      plural: 'strategy_objectives'
      name: 'strategy_objectives'
      className: 'StrategyObjective'
      human: 'Strategy Objective'
  SkippedParameters:
    RIGHTS_GROUPS:
      singular: 'rights_group'
      plural: 'rights_groups'
      name: 'rights_groups'
      className: 'RightsGroup'
      human: 'Rights Groups'

  Syncables:
    PLANS:
      singular: 'plan'
      plural: 'plans'
      className: 'Plan'
      human: 'Operations'
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
  Algorithms:
    SUCCESS_THRESHOLD: 0.66
    OK_THRESHOLD: 0.33
    HIGH_THRESHOLD: 0.8
    MEDIUM_THRESHOLD: 0.6
    STATUS:
      missing: 'missing'
      reported: 'reported'
    ALGO_RESULTS:
      success: 'success'
      ok: 'ok'
      fail: 'fail'
      high: 'high'
      medium: 'medium'
      low: 'low'

    REPORTED_VALUES:
      myr: 'myr'
      yer: 'yer'
      baseline: 'baseline'

    GOAL_TYPES:
      standard: 'standard'
      compTarget: 'comp_target'
      target: 'imp_target'

Visio.ProgressTypes =
  BASELINE_MYR:
    start: Visio.Algorithms.REPORTED_VALUES.baseline
    end: Visio.Algorithms.REPORTED_VALUES.myr
    value: "#{Visio.Algorithms.REPORTED_VALUES.baseline}#{Visio.Constants.SEPARATOR}#{Visio.Algorithms.REPORTED_VALUES.myr}"
  BASELINE_YER:
    start: Visio.Algorithms.REPORTED_VALUES.baseline
    end: Visio.Algorithms.REPORTED_VALUES.yer
    value: "#{Visio.Algorithms.REPORTED_VALUES.baseline}#{Visio.Constants.SEPARATOR}#{Visio.Algorithms.REPORTED_VALUES.yer}"
  MYR_YER:
    start: Visio.Algorithms.REPORTED_VALUES.myr
    end: Visio.Algorithms.REPORTED_VALUES.yer
    value: "#{Visio.Algorithms.REPORTED_VALUES.myr}#{Visio.Constants.SEPARATOR}#{Visio.Algorithms.REPORTED_VALUES.yer}"

Visio.AggregationTypes = [
    Visio.Parameters.OPERATIONS,
    Visio.Parameters.PPGS,
    Visio.Parameters.GOALS,
    Visio.Parameters.OUTPUTS,
    Visio.Parameters.PROBLEM_OBJECTIVES,
    Visio.Parameters.STRATEGY_OBJECTIVES,
  ]

Visio.Algorithms.CRITICALITIES = [
    { value: Visio.Algorithms.ALGO_RESULTS.success }
    { value: Visio.Algorithms.ALGO_RESULTS.ok }
    { value: Visio.Algorithms.ALGO_RESULTS.fail }
    { value: Visio.Algorithms.STATUS.missing }
  ]

Visio.Algorithms.THRESHOLDS = [
    { value: Visio.Algorithms.ALGO_RESULTS.high }
    { value: Visio.Algorithms.ALGO_RESULTS.medium }
    { value: Visio.Algorithms.ALGO_RESULTS.low }
    { value: Visio.Algorithms.STATUS.missing }
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
