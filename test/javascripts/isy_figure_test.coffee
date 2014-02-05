module 'ISY Figure',
  setup: ->
    @figure = new Visio.Figures.Isy
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100

test 'filtered', ->
  data = new Visio.Collections.IndicatorDatum([
    {
      id: 'ben'
      is_performance: false
    },
    {
      id: 'jeff'
      is_performance: true
    },
    {
      id: 'lisa'
      is_performance: true
    }
  ])

  @figure.isPerformanceFn true
  filtered = @figure.filtered data.models
  strictEqual filtered.length, 2


test 'data', ->
  data = new Visio.Collections.IndicatorDatum([
    {
      id: 'ben'
      is_performance: false
    },
    {
      id: 'jeff'
      is_performance: true
    },
    {
      id: 'lisa'
      is_performance: true
    }
  ])

  @figure.dataFn data.models
  strictEqual @figure.dataFn().length, 3
  ok @figure.dataFn() instanceof Array

  @figure.isPerformanceFn false
  @figure.dataFn data.models
  strictEqual @figure.dataFn().length, 3
  ok @figure.dataFn() instanceof Array

  @figure.isPerformanceFn(true)
  @figure.dataFn data.models
  strictEqual @figure.dataFn().length, 3
  ok @figure.dataFn() instanceof Array

test 'render', ->
  data = new Visio.Collections.IndicatorDatum([
    {
      id: 'ben'
      is_performance: false
      baseline: 0
      myr: 10
      yer: 20
      comp_target: 50
      standard: 50
    },
    {
      id: 'jeff'
      is_performance: true
      baseline: 0
      myr: 10
      yer: 20
      comp_target: 50
      standard: 50
    },
    {
      id: 'lisa'
      is_performance: true
      baseline: 0
      myr: 10
      yer: 20
      comp_target: 50
      standard: 50
    }
  ])

  @figure.isPerformanceFn false
  @figure.dataFn data.models
  @figure.render()

  ok @figure.$el.find('.box').length, 1
  ok @figure.$el.find('.box line').length, 1
