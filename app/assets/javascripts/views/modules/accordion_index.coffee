class Visio.Views.AccordionIndexView extends Backbone.View

  initialize: (options) ->
    @views = {}

    $.subscribe 'scroll.bottom', @onScrollBottom

  className: 'module'

  template: HAML['modules/accordion_index']

  humanName: 'My Accordion View'

  page: 0

  perPage: 20

  render: (isRerender, opts = {}) ->
    if !isRerender
      @$el.html @template(_.extend({ humanName: @humanName }, opts))

    @parameters = Visio.manager.selected(Visio.manager.get('aggregation_type')).models.sort @sort

    @page = 0
    @addPage @parameters, @page
    @page += 1
    @

  onScrollBottom: (e) =>
    @addPage @parameters, @page
    @page += 1

  addPage: (parameters, page) =>
    return unless parameters?
    start = page * @perPage
    end = (page + 1) * @perPage

    _.each parameters[start..end], @addOne

    ids = parameters.map (p) => p.refId().toString()
    @cleanViews ids

  addAll: (parameters) =>
    _.each parameters, @addOne

    ids = parameters.map (p) => p.refId().toString()
    @cleanViews ids

  # cleanViews: given an array of ids, will close all views that are not included in the list
  # @param ids - list of included ids
  #
  cleanViews: (ids) =>
    for id, view of @views
      unless _.include ids, id
        view.close()
        delete @views[id]

  addOne: (parameter, idx) =>
    isRerender = false
    viewId = parameter.refId().toString()
    if @views[viewId]
      @views[viewId].model = parameter
      isRerender = true
    else
      @views[viewId] = @showView({ model: parameter })
    @$el.append @views[viewId].render(isRerender).el

    @views[viewId].drawFigures?() if @views[viewId].isOpen()

  sort: (parameterA, parameterB) ->
    0

