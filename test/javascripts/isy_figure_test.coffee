module 'ISY Figure',
  setup: ->
    @el = $('<div></div>')[0]
    @graph = Visio.Figures.isy(
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100
      selection: d3.select(@el))

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

  @graph.isPerformance(true)
  filtered = @graph.filtered data.models
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

  @graph.data(data.models)
  strictEqual @graph.data().length, 3
  ok @graph.data() instanceof Array

  @graph.isPerformance(false)
  @graph.data(data.models)
  strictEqual @graph.data().length, 3
  ok @graph.data() instanceof Array

  @graph.isPerformance(true)
  @graph.data(data.models)
  strictEqual @graph.data().length, 3
  ok @graph.data() instanceof Array

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

  @graph.isPerformance(false)
  @graph.data(data.models)
  @graph()

  ok $(@el).find('.box').length, 1
  ok $(@el).find('.box line').length, 1
