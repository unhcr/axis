module 'Filter System',
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
    Visio.manager.set 'dashboard', Visio.manager.strategy()
    Visio.manager.resetSelectedDefaults()

    _.each _.values(Visio.Parameters), (hash) ->
      models = [{ id: 1 }, { id: 2 }]
      Visio.manager.get(hash.plural).reset(models)

    @view = new Visio.Views.FilterSystemView()

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
  strictEqual @view.$el.find('input[type="checkbox"]').length, 4

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

test 'onDeselect', ->
  @view.render()
  $('body').append @view.el

  strictEqual @view.$el.find('input:checked').length, 4

  @view.$el.find('.deselect').trigger 'click'
  strictEqual @view.$el.find('input:checked').length, 0

test 'onReset', ->
  @view.render()
  $('body').append @view.el

  strictEqual @view.$el.find('input:checked').length, 4

  $input = @view.$el.find('#check_1_operations')
  $input.trigger 'click'
  strictEqual @view.$el.find('input:checked').length, 3

  @view.$el.find('.reset').trigger 'click'
  strictEqual @view.$el.find('input:checked').length, 4
