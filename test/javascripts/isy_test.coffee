module 'ISY',
  setup: ->
    Visio.manager = new Visio.Models.Manager({
      selected:
        operations: { ben: true, lisa: true }
        ppgs: { abc: true, def: true }
        goals: { a: true, b: true }
      aggregation_type: Visio.Parameters.OPERATIONS.plural
    })
    Visio.manager.year(2012)
    Visio.manager.set 'use_cache', false
    Visio.manager.get(Visio.Parameters.OPERATIONS.plural).reset([
      {
        id: 'ben'
      },
      {
        id: 'lisa'
      },
      {
        id: 'g'
      }
    ])
    Visio.manager.get(Visio.Parameters.PPGS.plural).reset([
      { id: 'abc' }, { id: 'def' }
    ])
    Visio.manager.get(Visio.Parameters.GOALS.plural).reset([
      { id: 'a' }, { id: 'b' }
    ])
    @view = new Visio.Views.IsyView()


  teardown: ->
    Visio.manager.get('db').clear()


test 'render', ->

  @view.render()

  strictEqual _.keys(@view.views).length, 2

  Visio.manager.year(2013)
  @view.render()

  strictEqual _.keys(@view.views).length, 2

  Visio.manager.set 'aggregation_type', Visio.Parameters.PPGS.plural
  @view.render()

  strictEqual _.keys(@view.views).length, 2

  _.each Visio.manager.selected(Visio.Parameters.PPGS.plural).pluck('id'), (id) =>
    ok _.include(_.keys(@view.views), id)

  Visio.manager.set 'aggregation_type', Visio.Parameters.OPERATIONS.plural
  @view.render()
  strictEqual _.keys(@view.views).length, 2
  ok Visio.manager.get Visio.Parameters.OPERATIONS.plural

test 'sort', ->
  sinon.stub Visio.Models.Operation.prototype, 'selectedIndicatorData', ->
    if @id == 'ben'
      return new Visio.Collections.IndicatorDatum([{ id: 1 }, { id: 2 }, { id: 3 }])
    else if @id == 'g'
      return new Visio.Collections.IndicatorDatum([{ id: 4 }, { id: 5 }])
    else
      return new Visio.Collections.IndicatorDatum([{ id: 6 }])

  sinon.stub Visio.Collections.IndicatorDatum.prototype, 'situationAnalysis', ->
    analysis = { result: 1, total: 1 }
    if @length == 3
      analysis.result = 2
    else if @length == 2
      analysis.total = 2
    return analysis

  models = Visio.manager.get('operations').models.sort(@view.sort)

  strictEqual models[0].id, 'ben', 'Highest result should be first'
  strictEqual models[1].id, 'g', 'Next should be broken by total'

  Visio.Models.Operation.prototype.selectedIndicatorData.restore()
  Visio.Collections.IndicatorDatum.prototype.situationAnalysis.restore()
