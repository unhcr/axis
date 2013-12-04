window.Visio =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Utils: {}
  Graphs: {}
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
  Algorithms: {}

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
