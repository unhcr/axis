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

    @outputs = new Visio.Collections.Output([
      {
        id: 'abc-def'
        name: 'earth'
      },
      {
        id: 'def-abc'
        name: 'mars'
      }
    ])

    sinon.stub Visio.Collections.Output.prototype, 'selectedSituationAnalysis', (year, filters) ->
      console.log arguments
      counts = {}
      counts[Visio.Algorithms.ALGO_RESULTS.success] = 2
      counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
      counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
      counts[Visio.Algorithms.STATUS.missing] = if year == 2014 then 2 else 4
      return {
        result: .5
        counts: counts
        total: if year == 2014 then 4 else 0
        typeTotal: 2
      }

  teardown: ->
    Visio.Collections.Output.prototype.selectedSituationAnalysis.restore()

test 'filtered', ->


  filtered = @figure.filtered @outputs

  countedYears = _.filter Visio.manager.get('yearList'), (year) -> year <= (new Date()).getFullYear()

  strictEqual Visio.Collections.Output.prototype.selectedSituationAnalysis.callCount,
    countedYears.length


  _.each filtered, (lineData) ->
    switch lineData.category
      when Visio.Algorithms.ALGO_RESULTS.success
        strictEqual lineData.amount, 2 * lineData.length
      when Visio.Algorithms.STATUS.missing
        strictEqual lineData.amount, (4 * lineData.length) - 2
      else
        strictEqual lineData.amount, 0

test 'render', ->

  @figure.collectionFn @outputs
  @figure.render()

  strictEqual @figure.$el.find('.ic-line').length, 4

test 'selected', ->

  @figure.collectionFn @outputs
  @figure.render()

  filtered = @figure.filtered @outputs

  @figure.onMouseclickVoronoi { point: filtered[0][0] }, filtered

  strictEqual d3.select(@figure.el).selectAll('.icmy-point-selected').size(), filtered.length
  strictEqual @figure.selectedDatum.get('d'), filtered[0][0]

  @figure.onMouseclickVoronoi { point: filtered[0][0] }, filtered

  strictEqual d3.select(@figure.el).selectAll('.icmy-point-selected').size(), 0
  strictEqual @figure.selectedDatum.get('d'), null
