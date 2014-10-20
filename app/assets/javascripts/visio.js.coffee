window.Visio =
  Models: {}
  Collections: {}
  SelectedData: {}
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
      human: 'Indicators over time'
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
      human: 'Indicators vs Budget'
      name: 'absy'
    # Achievement Budget Single Year
    BSY:
      className: 'Bsy'
      human: 'Budget'
      name: 'bsy'
    # Budget Multiple Year
    BMY:
      className: 'Bmy'
      human: 'Budget over time'
      name: 'bmy'
    # Budget Multiple Year Summary
    BMY_SUMMARY:
      className: 'BmySummary'
      human: 'Budget over time'
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
    LYPL: 'Stateless'
    LYPJ: 'All populations of conern'
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
    # Width of entire export figure including legend
    EXPORT_WIDTH: 1000
    EXPORT_LEGEND_WIDTH: 300
    EXPORT_LABELS_WIDTH: 300
    EXPORT_LABELS_HEIGHT: 400
    EXPORT_HEIGHT: 800

    PDF_HEIGHT: 500

    ANY_YEAR: 'ANY_YEAR'
    ANY_STRATEGY_OBJECTIVE: 'ANY_STRATEGY_OBJECTIVE'
    DB_NAME: 'visio'
    SEPARATOR: '___'
    ALPHABET: 'abcdefghijklmnopqrstuvwxyz'
    CMS:
      TEXTAREA_MAXLEN: 900

  Texts:
    STRATEGY_DESC: 'Global strategies are defined by headquarters or regional offices. You can also create your own strategy or view strategies that others have shared with you.'
    STRATEGY_TITLE: 'Choose a strategy, operation or indicator to begin.'
    ABSY_LEGEND: 'This dashboard depicts the allocated budget for Operations, PPGs, Goals, Outputs, Objectives, and Strategy Objectives against achievements.'
    ISY_LEGEND: 'This dashboard displays the progress of each indicator. Each bar illustrates the percentage of progress from the baseline towards the target or standard. Details are showed on rollover.'
    ICMY_LEGEND: 'This dashboard displays the progress of indicators over time. The first line graph aggregates all indicators. Below there is a breakdown  for each element of the specified aggregation type (Operations, PPGs, Goals, Objectives, or Outputs).'
    BSY_LEGEND: 'This dashboard displays the budget for each element of the specified aggregation type (Operations, PPGs, Goals, Objectives, or Outputs). Each bar is broken down by budget components, pillars or scenarios (AOL, OL), depending on the filters.'
    BMY_LEGEND: 'This dashboard displays the trends in budget over time. The first line graph displays the budget for each element of the specified aggregation type (Operations, PPGs, Goals, Objectives, or Outputs), over time. Below there is a breakdown for each of the elements.'

  TooltipTexts:
    MENU_FILTER: 'Select a filter'
    MENU_STRATEGY: 'Select a strategy'
    MENU_INDICATOR: 'Select an indicator'
    MENU_OPERATION: 'Select an operation'

    HEADER_DASHBOARDS: 'Select a dashboard'
    HEADER_AGGREGATE: 'Define the element to aggregate by'
    HEADER_YEAR: 'Select the year'
    HEADER_REPORT_TYPE: 'Select Mid Year Report or Year End Report'

    TOOLBAR_NARRATIVE: 'Narrative for the selected element'
    TOOLBAR_SORT_BY: 'Sort the data'
    TOOLBAR_FILTER_BY: 'Filter options for displaying the data'
    TOOLBAR_EXPORT: 'Export as image or PDF'

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
    STRATEGIES:
      singular: 'strategy'
      plural: 'strategies'
      className: 'Strategy'
      human: 'Strategy'
    NARRATIVES:
      singular: 'narrative'
      plural: 'narratives'
      className: 'Narrative'
      human: 'Narrative'
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
      inconsistent: 'inconsistent'

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
    { value: Visio.Algorithms.ALGO_RESULTS.success, description: 'Percentage of indicators in an acceptable range.' }
    { value: Visio.Algorithms.ALGO_RESULTS.ok, description: 'Percentage of indicators in an unacceptable range.' }
    { value: Visio.Algorithms.ALGO_RESULTS.fail, description: 'Percentage of indicators in a critical range.' }
    { value: Visio.Algorithms.STATUS.missing, description: 'Percentage of indicators with missing data.' }
  ]

Visio.Algorithms.THRESHOLDS = [
    { value: Visio.Algorithms.ALGO_RESULTS.high, description: 'Percentage of indicators that have achieved over 60% of their target.' }
    { value: Visio.Algorithms.ALGO_RESULTS.medium, description: 'Percentage of indicators that have achieved over 60% of their target.' }
    { value: Visio.Algorithms.ALGO_RESULTS.low, description: 'Percentage of indicators that have achieved less than 60% of their target.' }
    { value: Visio.Algorithms.STATUS.missing, description: 'Percentage of indicators with missing data.' }
  ]

Visio.Dashboards = [
    Visio.FigureTypes.OVERVIEW,
    Visio.FigureTypes.MAP,
    Visio.FigureTypes.ABSY
    Visio.FigureTypes.ISY,
    Visio.FigureTypes.ICMY,
    Visio.FigureTypes.BSY,
    Visio.FigureTypes.BMY,
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
