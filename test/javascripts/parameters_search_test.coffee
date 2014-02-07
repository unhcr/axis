module 'Parameter Search',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    @view = new Visio.Views.ParameterSearch({ collection: Visio.manager.get('outputs') })

    _.each _.values(Visio.Parameters), (hash) ->
      models = [{ id: 1 }, { id: 2 }]
      Visio.manager.get(hash.plural).reset(models)


test 'render', ->
  @view.render()

  ok @view.$el.find('input').length, 1, 'Should have one search box'

test 'filterIds', ->

  filterIds = @view.filterIds(3)

  strictEqual filterIds.output_ids.length, 1
  strictEqual filterIds.output_ids[0], 3
  strictEqual _.keys(filterIds).length, _.keys(Visio.Parameters).length - 1

  for key, val of filterIds
    continue if key == 'output_ids'
    strictEqual val.length, 2, "#{key} must have 2 filter ids"

test 'dataTypes', ->

  view1 = new Visio.Views.ParameterSearch({ collection: Visio.manager.get('outputs') })
  strictEqual view1.dataTypes().length, 3

  view2 = new Visio.Views.ParameterSearch({ collection: Visio.manager.get('indicators') })
  strictEqual view2.dataTypes().length, 1
  strictEqual view2.dataTypes()[0], Visio.Syncables.INDICATOR_DATA
