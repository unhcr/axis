module 'Parameter Search',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    @view = new Visio.Views.ParameterSearch({ collection: Visio.manager.get('outputs') })

    _.each _.values(Visio.Parameters), (hash) ->
      models = [{ id: 1 }, { id: 2 }]
      Visio.manager.get(hash.plural).reset(models)

  teardown: ->
    @view.close()

test 'render', ->
  @view.render()

  ok @view.$el.find('input').length, 1, 'Should have one search box'

test 'filterIds', ->

  filterIds = @view.filterIds(@view.collection.name, 3)

  strictEqual filterIds.output_ids.length, 1
  strictEqual filterIds.output_ids[0], 3
  strictEqual _.keys(filterIds).length, _.keys(Visio.Parameters).length - 2

  for key, val of filterIds
    continue if key == 'output_ids'
    strictEqual val.length, 2, "#{key} must have 2 filter ids"

test 'dataTypes', ->

  view1 = new Visio.Views.ParameterSearch({ collection: Visio.manager.get('outputs') })
  strictEqual view1.dataTypes(view1.collection.name).length, 3

  view2 = new Visio.Views.ParameterSearch({ collection: Visio.manager.get('indicators') })
  strictEqual view2.dataTypes(view2.collection.name).length, 1
  strictEqual view2.dataTypes(view2.collection.name)[0], Visio.Syncables.INDICATOR_DATA

test 'dependencyTypes', ->
  view1 = new Visio.Views.ParameterSearch({ collection: Visio.manager.get('operations') })
  strictEqual view1.dependencyTypes(view1.collection.name).length, 1
  strictEqual view1.dependencyTypes(view1.collection.name)[0], Visio.Parameters.PPGS

  view2 = new Visio.Views.ParameterSearch({ collection: Visio.manager.get('strategy_objectives') })
  strictEqual view2.dependencyTypes(view2.collection.name).length, 4

  strictEqual view2.dependencyTypes(Visio.Parameters.GOALS).length, 0
  strictEqual view2.dependencyTypes(Visio.Parameters.OUTPUTS).length, 0
  strictEqual view2.dependencyTypes(Visio.Parameters.PROBLEM_OBJECTIVES).length, 0
  strictEqual view2.dependencyTypes(Visio.Parameters.INDICATORS).length, 0
