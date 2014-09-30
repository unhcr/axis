class Visio.Views.QueryBy extends Backbone.View

  name: 'query_by'

  template: HAML['tooltips/query_by']

  className: 'query-by header-button'

  events:
    'keyup input': 'onQuery'
    'focus input': 'onFocus'
    'blur input': 'onBlur'

  initialize: (options) ->
    @figure = options.figure
    @throttledRender = _.throttle @figure.render.bind(@figure), 300
    @placeholder = options.placeholder or "Search for a #{Visio.manager.get('aggregation_type')}"

  render: (isRerender) ->
    @$el.html @template({ figure: @figure, placeholder: @placeholder })
    @

  onFocus: (e) ->
    e.stopPropagation()
    @$el.addClass 'open'

  onBlur: (e) ->
    e.stopPropagation()
    @$el.removeClass 'open'

  onQuery: (e) ->
    e.stopPropagation()
    $target = $ e.currentTarget
    query = $target.val()


    @figure.query = query
    @throttledRender true

  close: ->
    @unbind()
    @remove()
