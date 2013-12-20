class Visio.Views.IndicatorSingleYearView extends Backbone.View

  template: JST['modules/indicator_single_year']

  initialize: (options) ->
    @views = {}


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
    @views[parameter.id] = new Visio.Views.IndicatorSingleYearShowView({ model: parameter })
    @$el.append @views[parameter.id].render().el

