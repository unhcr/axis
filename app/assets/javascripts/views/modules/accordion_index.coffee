class Visio.Views.AccordionIndexView extends Backbone.View

  initialize: (options) ->
    @views = {}

  className: 'module'

  template: HAML['modules/accordion_index']

  humanName: 'My Accordion View'

  render: (isRerender) ->
    if !isRerender
      @$el.html @template({ humanName: @humanName })

    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type')).models.sort @sort

    @addAll parameters
    @

  addAll: (parameters) =>
    _.each parameters, @addOne

    ids = parameters.map (p) => p.refId().toString()

    for id, view of @views
      unless _.include ids, id
        view.close()
        delete @views[id]

  addOne: (parameter) =>
    isRerender = false
    viewId = parameter.refId().toString()
    if @views[viewId]
      @views[viewId].model = parameter
      isRerender = true
    else
      @views[viewId] = @showView({ model: parameter })
    @$el.append @views[viewId].render(isRerender).el

  sort: (parameterA, parameterB) ->
    0

