module 'Navigation',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.set 'strategies', new Visio.Collections.Strategy [{
        id: 1,
        operation_ids: {1: true },
        ppg_ids: { 1: true }
        goal_ids: { 1: true }
        output_ids: { 1: true }
      }]
    Visio.manager.set 'strategy_id', 1
    Visio.manager.resetSelectedDefaults()

    _.each _.values(Visio.Parameters), (hash) ->
      models = [{ id: 1 }, { id: 2 }]
      Visio.manager.get(hash.plural).reset(models)

    @view = new Visio.Views.NavigationView()

  teardown: ->
    @view.close()

test 'render', ->
  @view.render()

  strictEqual @view.searches.length, _.values(Visio.Parameters).length
  strictEqual @view.$el.find('input:checked').length, 4

test 'onChangeSelection', ->
  @view.render()
  $('body').append @view.el

  strictEqual @view.searches.length, _.values(Visio.Parameters).length
  strictEqual @view.$el.find('input:checked').length, 4
  strictEqual @view.$el.find('input[type="checkbox"]').length, _.values(Visio.Parameters).length * 2

  $input = @view.$el.find('#check_1_operations')
  strictEqual $input.length, 1

  $input.trigger 'click'
  strictEqual @view.$el.find('input:checked').length, 3

  ok not Visio.manager.get('selected')['operations'][1], 'Should deselect'

  $input.trigger 'click'
  strictEqual @view.$el.find('input:checked').length, 4

  ok Visio.manager.get('selected')['operations'][1]

  $input = @view.$el.find('#check_2_operations')

  ok not Visio.manager.strategy().include 'operation', 2

  search = _.find @view.searches, (search) -> search.parameter().plural is 'operations'
  sinon.stub search, 'add', sinon.spy()

  $input.trigger 'click'
  strictEqual @view.$el.find('input:checked').length, 5

  ok search.add.calledOnce, 'add should be called once, but was ' + search.add.callCount
  search.add.restore()

