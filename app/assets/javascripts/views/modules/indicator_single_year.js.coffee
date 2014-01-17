class Visio.Views.IndicatorSingleYearView extends Backbone.View

  template: JST['modules/indicator_single_year']

  initialize: (options) ->
    @views = {}

  className: 'module'

  id: 'isy'

  render: (isRerender) ->
    if !isRerender
      @$el.html @template()


    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type')).sortBy (p) ->
      -p.selectedSituationAnalysis().result || 0

    @addAll(parameters)
    @


  addAll: (parameters) =>
    _.each parameters, @addOne

    ids = parameters.map (p) => @getViewId(p)
    # Close all other views
    for id, view of @views
      unless _.include(ids, id)
        view.close()
        delete @views[id]

  addOne: (parameter) =>
    isRerender = false
    viewId = @getViewId(parameter)
    if @views[viewId]
      @views[viewId].model = parameter
      isRerender = true
    else
      @views[viewId] = new Visio.Views.IndicatorSingleYearShowView({ model: parameter })
    @$el.append @views[viewId].render(isRerender).el

  getViewId: (parameter) =>
    # id must be string since we're comparing to key in hash which is always string
    (parameter.get('operation_id') || parameter.id).toString()
