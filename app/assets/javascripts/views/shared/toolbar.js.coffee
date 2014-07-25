class Visio.Views.ToolbarView extends Backbone.View

  template: HAML['shared/toolbar']

  initialize: (options) ->
    @render()

  events:
    'click .share-strategy': 'onShareStrategy'

  onChange: (selected) ->
    attribute = selected.value.split(Visio.Constants.SEPARATOR)[0]
    value = selected.value.split(Visio.Constants.SEPARATOR)[1]
    Visio.manager.set attribute, value

  render: () ->
    @$el.html @template()
    $selects = @$el.find('select')

    $selects.easyDropDown
      cutOff: 10,
      wrapperClass: 'dropdown'
      onChange: @onChange

    @$el.removeClass('gone')
    @

  onShareStrategy: ->
    $('body').append((new Visio.Views.ShareStrategy({
      collection: Visio.manager.get('dashboard').get('shared_users')
      strategy: Visio.manager.get('dashboard') })).render().el)


