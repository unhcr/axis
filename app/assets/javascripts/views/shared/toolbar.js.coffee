class Visio.Views.ToolbarView extends Backbone.View

  template: JST['shared/toolbar']

  initialize: (options) ->
    @render()

  onChange: (selected) ->
    attribute = selected.value.split(':')[0]
    value = selected.value.split(':')[1]
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
