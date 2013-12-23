class Visio.Views.IndicatorSingleYearView extends Backbone.View

  template: JST['modules/indicator_single_year']

  initialize: (options) ->
    @views = {}

  className: 'module'

  render: (isRerender) ->
    if !isRerender
      @$el.html @template()


    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type')).sortBy (p) ->
      -p.selectedSituationAnalysis().result || 0

    @addAll(parameters)
    @


  addAll: (parameters) =>
    _.each parameters, @addOne

  addOne: (parameter) =>
    isRerender = false
    view_id = parameter.get('operation_id') || parameter.id
    if @views[view_id]
      @views[view_id].model = parameter
      isRerender = true
    else
      @views[view_id] = new Visio.Views.IndicatorSingleYearShowView({ model: parameter })
    @$el.append @views[view_id].render(isRerender).el

