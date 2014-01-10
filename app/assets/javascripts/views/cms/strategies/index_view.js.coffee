class Visio.Views.StrategyCMSIndexView extends Backbone.View

  template: JST['cms/strategies/index']

  events:
    'click .new': 'onClickNew'

  initialize: ->
    @render()

  render: ->
    @$el.html @template(strategies: @collection.toJSON())

  onClickAdd: ->
    Visio.router.navigate '/new', { trigger: true }
