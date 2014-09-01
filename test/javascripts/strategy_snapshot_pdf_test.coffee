module 'PDF - Strategy Snapshot',
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

    Visio.exportModule = new Visio.Models.ExportModule
      figure_config:
        collection: @o.toJSON()
        collectionName: 'Operation'
        viewLocation: 'Views'
        type: Visio.FigureTypes.OVERVIEW
      figure: @view

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
    @o.each (op) ->
      op.strategySituationAnalysis.restore()

test 'render', ->
  figureConfig = Visio.exportModule.get('figure_config')
  options = _.extend { isPdf: true }, figureConfig
  view = new Visio[figureConfig.viewLocation][figureConfig.type.className](options)
  view.render()
  count = view.collection.length + 1

  ok not view.actionSlider?
  ok view.parameterSlider.isPdf

  strictEqual view.$el.find('.bar-figure').length, 3
  strictEqual view.$el.find('.svg-pasy-figure').length, 2*count, 'Should have correct count of PASY'
  strictEqual view.$el.find('.svg-icsy-figure').length, count, 'Should have correct count of ICSY'

