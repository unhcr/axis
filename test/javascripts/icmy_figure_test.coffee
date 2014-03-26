module 'ICMY Figure',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Icmy
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100

    @outputs = Fixtures.outputs
    sinon.stub Visio.Models.Output.prototype, 'selectedSituationAnalysis', ->
      if @id == 'abc-def'
        counts = {}
        counts[Visio.Algorithms.ALGO_RESULTS.success] = 2
        counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
        counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
        counts[Visio.Algorithms.STATUS.missing] = 2
        return {
          result: .5
          counts: counts
          total: 4
          typeTotal: 3
        }
      else
        counts = {}
        counts[Visio.Algorithms.ALGO_RESULTS.success] = 0
        counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
        counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
        counts[Visio.Algorithms.STATUS.missing] = 2
        return {
          result: .5
          counts: counts
          total: 0
          typeTotal: 2
        }

  teardown: ->
    Visio.Models.Output.prototype.selectedSituationAnalysis.restore()

test 'filtered', ->


  filtered = @figure.filtered @outputs

  countedYears = _.filter Visio.manager.get('yearList'), (year) -> year + 1 <= (new Date()).getFullYear()

  strictEqual Visio.Models.Output.prototype.selectedSituationAnalysis.callCount,
    @outputs.length * countedYears.length


  _.each filtered, (lineData) ->
    switch lineData.category
      when Visio.Algorithms.ALGO_RESULTS.success
        strictEqual lineData.amount, 2 * lineData.length
      when Visio.Algorithms.STATUS.missing
        strictEqual lineData.amount, 4 * lineData.length
      else
        strictEqual lineData.amount, 0

test 'render', ->

  @figure.collectionFn @outputs
  @figure.render()

  strictEqual @figure.$el.find('.ic-line').length, 4

