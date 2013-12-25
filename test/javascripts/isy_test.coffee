module 'ISY',
  setup: ->
    Visio.manager = new Visio.Models.Manager({
      selected:
        plans: { ben: true, lisa: true }
        ppgs: { abc: true, def: true }
        goals: { a: true, b: true }
      aggregation_type: Visio.Parameters.PLANS.plural
    })
    Visio.manager.year(2012)
    Visio.manager.get(Visio.Parameters.PLANS.plural).reset([
      {
        id: 'ben'
        operation_id: 'tex'
        year: 2012
      },
      {
        id: 'lisa'
        operation: 'ill'
        year: 2012
      },
      {
        id: 'g'
        operation: 'ill'
        year: 2013
      }
    ])
    Visio.manager.get(Visio.Parameters.PPGS.plural).reset([
      { id: 'abc' }, { id: 'def' }
    ])
    Visio.manager.get(Visio.Parameters.GOALS.plural).reset([
      { id: 'a' }, { id: 'b' }
    ])
    @view = new Visio.Views.IndicatorSingleYearView()


test 'getViewId', ->
  p = Visio.manager.plan 'ben'

  strictEqual @view.getViewId(p), 'tex', 'Operation ID should be the view ID'

  p = Visio.manager.get(Visio.Parameters.PPGS.plural).get 'abc'

  strictEqual @view.getViewId(p), 'abc'

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

  Visio.manager.set 'aggregation_type', Visio.Parameters.PLANS.plural
  @view.render()
  strictEqual _.keys(@view.views).length, 2
  ok Visio.manager.get Visio.Parameters.PLANS.plural
