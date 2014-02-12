class Visio.Views.ActionSlideView extends Backbone.View

  template: HAML['sliders/action_slide']

  initialize: (options) ->
    @idx = options.idx

  render: ->
    @$el.html @template({ model: @model, idx: @idx })
    @

