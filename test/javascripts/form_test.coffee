module 'Form',
  setup: ->
    @model = new Visio.Models.Syncable()
    @model.schema = [{
        name: 'name',
        type: 'string',
        human: 'Name',
        formElement: 'text',
      }, {
        name: 'operations',
        human: 'Operations',
        formElement: 'checkboxes',
        type: 'collection',
        collection: -> new Visio.Collections.Operation()
      }, {
        name: 'strategy_objectives',
        human: 'Strategy Objectives',
        formElement: 'list',
        type: 'collection',
        model: -> new Visio.Models.StrategyObjective(),
        collection: -> new Visio.Collections.StrategyObjective()
      }]

    @form = new Visio.Views.Form
      model: @model

  teardown: ->
    @form.close() if @form?

test 'initSchema - new model', ->
  ok not @form.isSchemaInit, 'Should start out false'
  ok not @model.get('operations')?

  spy = sinon.spy()
  spy2 = sinon.spy()

  @form.on 'initialize', spy
  @form.on 'initialize:operations', spy2

  @form.initSchema()

  ok @form.isSchemaInit, 'Should be initialized'

  ok spy.calledOnce, 'Should be called once, once by the general'
  ok spy2.calledOnce, 'Should be called once, once by the operations'

  # New model so should have set collection
  ok @model.get('operations') instanceof Visio.Collections.Operation

test 'initSchema - existing model', ->
  @model.id = 'something'
  @model.set 'operations', new Visio.Collections.Operation [{ id: 1 }, { id: 2}]

  ok not @model.isNew()

  @form.initSchema()


  # Should not touch any of the fields
  strictEqual @model.get('operations').length, 2
  ok not @model.get('name')?

  ok @model.get('operations') instanceof Visio.Collections.Operation

  # Should have selected operations
  @model.get('operations').each (o) =>
    formField = @form.fields.findWhere { name: 'operations' }
    ok formField.selected(o.id), 'should be selected'

test 'render', ->
  @model.id = 'something'
  @model.set 'operations', new Visio.Collections.Operation [{ id: 1 }, { id: 2}]
  @form.initSchema()

  spy = sinon.spy()
  @form.on 'rendered', spy
  @form.render()


  strictEqual @form.$el.find(".form-field").length, 3
  strictEqual @form.$el.find('.form-operations input:checked').length, 2, 'Should have 2 checked operations'

  ok spy.calledOnce

test 'nestedItem - new model', ->
  @form.initSchema()
  @form.render()

  spy = sinon.spy()

  @form.on 'initialize:strategy_objectives:goals', spy
  so = new Visio.Models.StrategyObjective { attr: 'ben', goals: [{ id: 1 }] }
  @form.nestedItem so

  ok spy.calledOnce, 'Should have called initialize event for Strategy Objective goals'

  ok @form.model.get('strategy_objectives') instanceof Visio.Collections.StrategyObjective
  strictEqual @form.model.get('strategy_objectives').length, 0

  @form.nestedForms['strategy_objectives'][so.cid].render()
  @form.nestedForms['strategy_objectives'][so.cid].saveAndClose()
  strictEqual @form.model.get('strategy_objectives').length, 1
  strictEqual @form.model.get('strategy_objectives').at(0).get('goals').length, 1

test 'nestedTrigger', ->
  @form.initSchema()
  @form.render()
  so = new Visio.Models.StrategyObjective()
  @form.nestedItem so

  spy = sinon.spy()
  spy2 = sinon.spy()

  # Get nested form
  nested = @form.nestedForms['strategy_objectives'][so.cid]
  name = 'description'

  field = nested.fields.findWhere { name: name }

  @form.on "custom:strategy_objectives:#{name}", spy
  nested.on 'custom:description', spy2

  nested.nestedTrigger 'custom', field, 'dummy', 'dummy2'

  ok spy.calledOnce, "Should have been called once, but was #{spy.callCount}"
  strictEqual spy.args[0][0].cid, @form.cid
  strictEqual spy.args[0][1].cid, nested.cid
  strictEqual spy.args[0][2].cid, nested.model.cid

  ok spy2.calledOnce, "Should have been called once, but was #{spy2.callCount}"
  strictEqual spy2.args[0].length, 6
  strictEqual spy2.args[0][0].cid, nested.cid
  strictEqual spy2.args[0][1].cid, nested.model.cid
  strictEqual spy2.args[0][4], 'dummy'
  strictEqual spy2.args[0][5], 'dummy2'

  @form.on 'custom:strategy_objectives', spy
  nested.on 'custom', spy2

  nested.nestedTrigger 'custom'

  ok spy.calledTwice, "Should have been called once, but was #{spy.callCount}"
  ok spy2.calledTwice, "Should have been called once, but was #{spy2.callCount}"

test 'change', ->
  @model.id = 'something'
  @model.set 'operations', new Visio.Collections.Operation [{ id: 1 }, { id: 2}]

  @form.initSchema()
  @form.render()
  so = new Visio.Models.StrategyObjective()
  @form.nestedItem so
  nested = @form.nestedForms['strategy_objectives'][so.cid]

  name = 'operations'
  field = @form.fields.findWhere { name: name }

  ok field.selected(1), 'Should be selected'
  @form.change name, field, false, 1
  ok not field.selected(1), 'Should not be selected'


  name = 'name'
  field = @form.fields.findWhere { name: name }
  spy = sinon.spy()

  @form.on 'change:name', spy
  @form.change name, field, 'abc'
  ok spy.calledOnce

  field = nested.fields.findWhere { name: name }
  @form.on 'change:strategy_objectives:name', spy
  nested.change name, field, 'def'
  ok spy.calledTwice


test 'commit - no save', ->
  @model.id = 'something'
  @model.set 'operations', new Visio.Collections.Operation [{ id: 1 }, { id: 2}]

  @form.initSchema()
  @form.render()

  so = new Visio.Models.StrategyObjective()
  @form.nestedItem so

  field = @form.fields.findWhere { name: 'operations' }
  field.selected 1, false

  console.log @form.model.get 'operations'

  json = @form.commit()

  strictEqual json.operations.length, 2
  strictEqual json.strategy_objectives.length, 0

  json = @form.commit(false)

  strictEqual json.operations.length, 2
  strictEqual json.strategy_objectives.length, 0

test 'commit - save', ->
  @model.id = 'something'
  @model.set 'operations', new Visio.Collections.Operation [{ id: 1 }, { id: 2}]


  @form.initSchema()
  @form.render()

  so = new Visio.Models.StrategyObjective()
  @form.nestedItem so

  field = @form.fields.findWhere { name: 'operations' }
  field.selected 1, false

  @form.nestedForms['strategy_objectives'][so.cid].saveAndClose()

  json = @form.commit(true)

  strictEqual json.operations.length, 1
  strictEqual json.strategy_objectives.length, 1

test 'close - no save nested, save parent', ->
  @model.id = 'something'
  @model.set 'operations', new Visio.Collections.Operation [{ id: 1 }, { id: 2}]
  @model.set 'strategy_objectives', new Visio.Collections.StrategyObjective [{ id: 1 }, { id: 2}]

  @form.initSchema()
  @form.render()

  so = new Visio.Models.StrategyObjective()
  @form.nestedItem so
  nested = @form.nestedForms['strategy_objectives'][so.cid]
  nested.close()

  json = @form.saveAndClose()

  strictEqual json.operations.length, 2
  strictEqual json.strategy_objectives.length, 2

test 'close - save nested, save parent', ->
  @model.id = 'something'
  @model.set 'operations', new Visio.Collections.Operation [{ id: 1 }, { id: 2}]
  @model.set 'strategy_objectives', new Visio.Collections.StrategyObjective [{ id: 1 }, { id: 2}]

  @form.initSchema()
  @form.render()

  so = new Visio.Models.StrategyObjective()
  @form.nestedItem so
  nested = @form.nestedForms['strategy_objectives'][so.cid]
  nested.saveAndClose()

  json = @form.saveAndClose()

  strictEqual json.operations.length, 2
  strictEqual json.strategy_objectives.length, 3

test 'remove nested model', ->
  @model.id = 'something'
  @model.set 'strategy_objectives', new Visio.Collections.StrategyObjective [{ id: 1, name: 'blue' },
    { id: 2, name: 'red' }]

  @form.initSchema()
  spy = sinon.spy()
  @form.on 'remove:strategy_objectives', spy
  @form.render()

  strictEqual @form.$el.find('.form-strategy_objectives .nested-item').length, 2

  $item = @form.$el.find('.form-strategy_objectives .nested-item').eq 0
  $item.find('.nested-delete').trigger 'click'

  ok spy.calledOnce
  strictEqual @form.$el.find('.form-strategy_objectives .nested-item').length, 1


