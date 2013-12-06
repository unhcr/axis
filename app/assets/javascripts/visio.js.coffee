window.Visio =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Utils: {}
  Graphs: {}
  Formats:
    SI: d3.format('.3s')
  Constants:
    DB_NAME: 'visio'
  Stores:
    MAP: 'map'
    SYNC: 'sync_date'
  Parameters:
    PLANS: 'plans'
    PPGS: 'ppgs'
    GOALS: 'goals'
    OUTPUTS: 'outputs'
    PROBLEM_OBJECTIVES: 'problem_objectives'
    INDICATORS: 'indicators'
    INDICATOR_DATA: 'indicator_data'
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


Visio.Schema =
    stores: [
      {
        name: Visio.Parameters.PLANS + '_store'
        keyPath: 'id'
        autoIncrement: false
      },
      {
        name: Visio.Parameters.PPGS + '_store'
        keyPath: 'id'
        autoIncrement: false
      },
      {
        name: Visio.Parameters.GOALS + '_store'
        keyPath: 'id'
        autoIncrement: false
      },
      {
        name: Visio.Parameters.OUTPUTS + '_store'
        keyPath: 'id'
        autoIncrement: false
      },
      {
        name: Visio.Parameters.PROBLEM_OBJECTIVES + '_store'
        keyPath: 'id'
        autoIncrement: false
      },
      {
        name: Visio.Parameters.INDICATORS + '_store'
        keyPath: 'id'
        autoIncrement: false
      },
      {
        name: Visio.Parameters.INDICATOR_DATA + '_store'
        keyPath: 'id'
        autoIncrement: false
      },
      {
        name: Visio.Stores.MAP
        autoIncrement: false
      },
      {
        name: Visio.Stores.SYNC
        autoIncrement: false
      },
    ]
