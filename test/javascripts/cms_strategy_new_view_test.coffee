module 'CMS Strategy New/Edit View',
  setup: ->
    Visio.manager = new Visio.Models.Manager()

    @strategies = new Visio.Collections.Strategy(
      [{ id: 1 }, { id: 2 }])

    models = [
      {
        id: 'abc',
        name: 'BEN'
      }, {
        id: 'def',
        name: 'LISA'
      }, {
        id: 1,
        name: 'JILL'
      }
    ]

    synced = { new: models, updated: [], deleted: [] }
    @server = sinon.fakeServer.create()
    @server.respondWith 'GET', /.*/, (request) ->
      parts = request.url.split '?'
      console.log parts[1]
      if parts[1]? and parts[1].indexOf('join_ids') != -1
        return [200, {'Content-Type': 'application/json'}, JSON.stringify([models[0]])]

      [200, {'Content-Type': 'application/json'}, JSON.stringify(models)]
    @view = null

  teardown: ->
    @server.restore()
    @view.close() if @view?

test 'New View', ->
  @view = new Visio.Views.StrategyCMSEditView
    collection: @strategies
    model: new Visio.Models.Strategy()

  callback = =>
    # This render shoudl be called from rerendering when fetching
    strictEqual @view.model.get('operations').length, 3,
      "Length should be 3 and is #{@view.model.get('operations').length}"

  spy = sinon.spy callback

  console.log 'event'
  @view.form.on 'rendered', ->
    console.log 'here'
    spy()
    ok spy.calledOnce, "Should be called once and is called #{spy.callCount}"

  @server.respond()
  ok @view.model.get('operations') instanceof Visio.Collections.Operation,
    'Should initialize colleciton'
  ok @view.model.get('strategy_objectives') instanceof Visio.Collections.StrategyObjective,
    'Should initialize colleciton'

  strictEqual @view.model.get('strategy_objectives').length, 0,
    "Length should be 3 and is #{@view.model.get('strategy_objectives').length}"

test 'fetchRelatedParameter', ->
  @view = new Visio.Views.StrategyCMSEditView
    collection: @strategies
    model: new Visio.Models.Strategy()

  so = new Visio.Models.StrategyObjective()
  spy = sinon.spy()

  @view.form.nestedItem so

  o = @view.form.nestedForms[so.name.plural][so.cid].fields.findWhere { name: 'outputs' }
  po = @view.form.nestedForms[so.name.plural][so.cid].fields.findWhere { name: 'problem_objectives' }

  o.selected 1, true
  po.selected 2, true

  @server.respond()
  strictEqual @server.requests.length, 2, "Should have made 2 requests"

  @view.fetchRelatedParameter @view.form.nestedForms['strategy_objectives'][so.cid],
    so, Visio.Parameters.PROBLEM_OBJECTIVES, Visio.Parameters.INDICATORS

  @server.respond()
  strictEqual @server.requests.length, 4, "Should have made 4 requests"

test 'Nested View - initialize', ->
  ok true

test 'Nested View - change', ->
  ok true
