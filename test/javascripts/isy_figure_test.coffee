module 'ISY Figure',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Isy
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100

    Visio.manager.get('indicators').reset [
      {
        id: 'wilson'
        name: 'willy'
      },
      {
        id: 'george'
        name: 'bigG'
      }
    ]

    @data = new Visio.Collections.IndicatorDatum([
        {
          id: 'ben'
          is_performance: false
          baseline: 0
          myr: 10
          yer: 20
          imp_target: 50
          standard: 50
          indicator_id: 'wilson'
        },
        {
          id: 'jeff'
          is_performance: true
          baseline: 0
          myr: 20
          yer: 20
          imp_target: 50
          standard: 50
          indicator_id: 'wilson'
        },
        {
          id: 'lisa'
          is_performance: true
          baseline: 0
          myr: 30
          yer: 20
          imp_target: 50
          standard: 50
          indicator_id: 'george'
        }
      ])

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
  filtered = @figure.filtered data
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

  @figure.collectionFn data
  strictEqual @figure.collectionFn().length, 3
  ok @figure.collectionFn() instanceof Visio.Collections.IndicatorDatum

  @figure.isPerformanceFn false
  @figure.collectionFn data
  strictEqual @figure.collectionFn().length, 3
  ok @figure.collectionFn() instanceof Visio.Collections.IndicatorDatum

  @figure.isPerformanceFn(true)
  @figure.collectionFn data
  strictEqual @figure.collectionFn().length, 3
  ok @figure.collectionFn() instanceof Visio.Collections.IndicatorDatum

test 'render', ->

  @figure.isPerformanceFn false
  @figure.collectionFn @data
  @figure.render()

  strictEqual @figure.$el.find('.box').length, 1
  strictEqual @figure.$el.find('.box line').length, 1

test 'sort', ->
  @figure.sortAttribute = Visio.ProgressTypes.BASELINE_MYR
  @figure.isPerformanceFn true

  sorted = @figure.filtered @data
  strictEqual sorted[0].id, 'lisa'
  strictEqual sorted[1].id, 'jeff'

test 'findBoxByDatum', ->
  @figure.isPerformanceFn true
  @figure.sortAttribute = Visio.ProgressTypes.BASELINE_MYR
  @figure.collectionFn @data
  @figure.render()
  strictEqual @figure.$el.find('.box').length, 2

  datum = @data.get 'jeff'
  result = @figure.findBoxByDatum datum

  ok result.box.classed("box-#{datum.id}")
  ok result.idx, 1
  strictEqual result.datum.id, datum.id


test 'findBoxByIndex', ->
  @figure.isPerformanceFn true
  @figure.sortAttribute = Visio.ProgressTypes.BASELINE_MYR
  @figure.collectionFn @data
  @figure.render()
  strictEqual @figure.$el.find('.box').length, 2

  datum = @data.get 'jeff'
  result = @figure.findBoxByIndex 1

  ok result.box.classed("box-#{datum.id}")
  ok result.idx, 1
  strictEqual result.datum.id, 'jeff'

test 'hover - datum', ->
  @figure.isPerformanceFn true
  @figure.sortAttribute = Visio.ProgressTypes.BASELINE_MYR
  @figure.collectionFn @data
  @figure.render()


  datum = @data.get 'jeff'
  $.publish "hover.#{@figure.cid}.figure", datum

  strictEqual @figure.hoverDatum.id, datum.id
  ok @figure.$el.find(".box-#{datum.id} .hover").length, 'Should have hover element'

test 'hover - idx', ->
  @figure.isPerformanceFn true
  @figure.sortAttribute = Visio.ProgressTypes.BASELINE_MYR
  @figure.collectionFn @data
  @figure.render()


  datum = @data.get 'jeff'
  $.publish "hover.#{@figure.cid}.figure", 1

  strictEqual @figure.hoverDatum.id, datum.id
  ok @figure.$el.find(".box-#{datum.id} .hover").length, 'Should have hover element'

test 'computeLabelPositions', ->

  datum = @data.get 'jeff'
  @figure.y.domain [0, 100]
  @figure.y.range [0, 100]
  datum.set Visio.Algorithms.REPORTED_VALUES.myr, 21
  datum.set Visio.Algorithms.REPORTED_VALUES.yer, 20
  length = 20

  attributes = [Visio.Algorithms.REPORTED_VALUES.myr, Visio.Algorithms.REPORTED_VALUES.yer]

  hash = @figure.computeLabelPositions attributes, datum, length

  strictEqual _.values(hash).length, 2

  positions = _.values(hash).sort()

  ok positions[1] > positions[0]
  strictEqual positions[1] - positions[0], length

test 'query', ->

  @figure.isPerformanceFn true
  @figure.query = 'willy'
  strictEqual @figure.filtered(@data).length, 1, 'Should not be filtered'

  @figure.query = ''
  strictEqual @figure.filtered(@data).length, 2, 'Should not be filtered'

  @figure.query = 'g'
  strictEqual @figure.filtered(@data).length, 1, 'Should not be filtered'
