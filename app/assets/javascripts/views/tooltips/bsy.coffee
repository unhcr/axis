class Visio.Views.BsyTooltip extends Backbone.View

  name: 'bsy'

  template: HAML['tooltips/bsy']

  initialize: (options) ->
    @figure = options?.figure
    @rendered = false

    super options

  render: (d) ->
    return unless d?
    @rendered = true

    @$el.html @template({ d: d })
    @

  hasRendered: =>
    @rendered

  close: =>
    @remove()
    @unbind()

