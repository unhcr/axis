module 'Share Strategy',
  setup: ->
    @strategy = new Visio.Models.Strategy
      shared_users: [{ id: 1, login: 'ben' }, { id: 2, login: 'lisa' }]

    Visio.manager = new Visio.Models.Manager({
      dashboard: @strategy,
      personal_strategies: new Visio.Collections.Strategy([@strategy])
    })


test 'render', ->

  @view = new Visio.Views.ShareStrategy
    strategy: @strategy

  ok @view.$el.hasClass 'modal'
  strictEqual @view.$el.find('.user-pill').length, 2
  @view.close()

test 'onUserRemove', ->
  @view = new Visio.Views.ShareStrategy
    strategy: @strategy

  @view.$el.find('.user-pill .close:first').trigger('click')
  strictEqual @view.$el.find('.user-pill').length, 1

  strictEqual @strategy.get('shared_users').length, 1
  @view.close()

