class Visio.Views.FilterBy extends Backbone.View

  name: 'filter_by'

  template: HAML['tooltips/filter_by']

  events:
    'change input': 'onFilter'

  initialize: (options) ->
    @figure = options.figure

  render: (isRerender) ->
    @$el.html @template({ figure: @figure })
    @

  onFilter: (e) ->
    $target = $(e.currentTarget)
    console.log $target.val()

    type = $target.val().split(Visio.Constants.SEPARATOR)[0]
    attr = $target.val().split(Visio.Constants.SEPARATOR)[1]
    active = $target.is ':checked'

    @figure.filters.get(type).filter(attr, active)
    @figure.render()
