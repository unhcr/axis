module 'Strategy Snapshot',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.get('strategies').reset([{
      id: 1,
      name: 'ben',
      description: 'lovely'
      operation_ids: { 1: true, 2: true, 3: true, 4: true }
    }])
    Visio.manager.set 'strategy_id', 1
    Visio.manager.set 'aggregation_type', Visio.Parameters.OPERATIONS.plural
    @o = new Visio.Collections.Operation([
        { id: 1, name: 'Angola', country: { iso2: 'US' } },
        { id: 2, name: 'Chad', country: { iso2: 'US' } },
        { id: 3, name: 'Rwanda', country: { iso2: 'US' } },
        { id: 4, name: 'Uganda', country: { iso2: 'US' } }
      ])

    Visio.manager.set 'operations', @o
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

  count = @view.criticalities.length * (@view.collection.length + 1)

  strictEqual @view.$el.find('.criticality').length, count
  strictEqual @view.$el.find('.keyFigure').length, count

test 'sliders', ->
  @view.render()

  strictEqual @view.parameterSlider.position, 0
  sinon.spy @view.parameterSlider, 'move'
  @view.$el.find('.target-parameters .next').trigger 'click'
  ok @view.parameterSlider.move.calledOnce
  strictEqual @view.$el.find('.slide').length, 4

  @view.$el.find('.target-parameters .next').trigger 'click'
  ok @view.parameterSlider.move.calledTwice
  strictEqual @view.$el.find('.slide').length, 4

  @view.render()

  @view.$el.find('.target-parameters .next').trigger 'click'
  strictEqual @view.$el.find('.slide').length, 4
  ok @view.parameterSlider.move.calledThrice
