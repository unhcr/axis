module 'Strategy Snapshot',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.set 'selected', {
        operations: { 1: true, 2: true, 3: true, 4: true },
        ppgs: {},
        strategy_objectives: {},
        outputs: {},
        problem_objectives: {}
        goals: {}
        indicators: {}
      }

    Visio.manager.get('strategies').reset([{
      id: 1
      name: 'the name'
      description: 'the description'
    }])
    Visio.manager.set 'strategy_id', 1
    Visio.manager.set 'dashboard', Visio.manager.strategy()

    Visio.manager.set { 'aggregation_type': Visio.Parameters.OPERATIONS.plural }, { silent: true }
    @o = new Visio.Collections.Operation([
        { id: 1, name: 'Angola', country: { iso2: 'US' } },
        { id: 2, name: 'Chad', country: { iso2: 'US' } },
        { id: 3, name: 'Rwanda', country: { iso2: 'US' } },
        { id: 4, name: 'Uganda', country: { iso2: 'US' } }
      ])

    Visio.manager.set 'operations', @o
    @view = new Visio.Views.SnapshotView
      collection: @o

    @o.each (op) ->
      sinon.stub op, 'selectedSituationAnalysis', ->
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
      op.selectedSituationAnalysis.restore()


test 'keyFigures', ->
  console.log Visio.manager.get('selected')
  _.each @view.keyFigures, (keyFigure) =>
    ok @view[keyFigure.fn] instanceof Function, 'Must be a function tied to keyFigure'
    ok _.isString(typeof keyFigure.human), 'Must have human readable'


test 'render', ->
  @view.render()

  count = @view.collection.length + 1

  strictEqual @view.$el.find('.bar-figure').length, count * 3
  strictEqual @view.$el.find('.keyFigure').length, count * 2
