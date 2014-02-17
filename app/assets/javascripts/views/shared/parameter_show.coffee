class Visio.Views.ParameterShowView extends Backbone.View

  className: 'col-md-6 col-sm-6 parameter'

  template: HAML['shared/parameter_show']

  initialize: (options) ->
    @idx = options.idx


  render: ->
    @$el.html @template({ model: @model, idx: @idx })
    @
