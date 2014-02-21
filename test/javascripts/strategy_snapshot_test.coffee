module 'Strategy Snapshot',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.get('strategies').reset([{ id: 1, name: 'ben', description: 'lovely' }])
    Visio.manager.set 'strategy_id', 1
    @o = new Visio.Collections.Operation([
        { id: 1, name: 'Angola' },
        { id: 2, name: 'Chad' },
        { id: 3, name: 'Rwanda' },
        { id: 4, name: 'Uganda' }
      ])

    @view = new Visio.Views.StrategySnapshotView
      collection: @o

    @o.each (op) ->
      sinon.stub op, 'strategySituationAnalysis', ->
        counts = {}
        counts[Visio.Algorithms.ALGO_RESULTS.success] = 0
        counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
        counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
        counts[Visio.Algorithms.STATUS.missing] = 0
        return {
          counts: counts
          total: 5
        }
  teardown: ->
    @view.close()
    @o.each (op) ->
      op.strategySituationAnalysis.restore()


test 'keyFigures', ->
  _.each @view.keyFigures, (keyFigure) =>
    ok @view[keyFigure.fn] instanceof Function, 'Must be a function tied to keyFigure'
    ok _.isString(typeof keyFigure.human), 'Must have human readable'


test 'render', ->
  @view.render()

  strictEqual @view.$el.find('.criticality').length, @view.criticalities.length
  strictEqual @view.$el.find('.keyFigure').length, @view.keyFigures.length

