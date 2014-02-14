module 'Spark Figure',
  setup: ->

    @figure = new Visio.Figures.Spark
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100


    @d = new Visio.Models.Output({ id: 1 })
    sinon.stub @d, 'selectedAmount', -> 10
    sinon.stub @d, 'selectedSituationAnalysis', ->
      counts = {}
      counts[Visio.Algorithms.ALGO_RESULTS.ok] = 2
      counts[Visio.Algorithms.ALGO_RESULTS.success] = 2
      counts[Visio.Algorithms.ALGO_RESULTS.fail] = 2
      counts[Visio.Algorithms.STATUS.missing] = 2
      return {
        counts: counts
      }

  teardown: ->
    @d.selectedAmount.restore()
    @d.selectedSituationAnalysis.restore()

test 'filtered', ->
  filtered = @figure.filtered [@d]

  strictEqual filtered.length, 4, 'Filtered length should be 4'
  strictEqual @d.selectedSituationAnalysis.callCount, 1, 'Should call sit. anal. once'

  _.each filtered, (d) ->
    strictEqual d.value, 2, 'Should have a value of 2 for each count'

test 'render', ->
  @figure.dataFn [@d]
  @figure.render()

  strictEqual @figure.$el.find('.bar').length, 4, 'Should have 4 bars rendered'
