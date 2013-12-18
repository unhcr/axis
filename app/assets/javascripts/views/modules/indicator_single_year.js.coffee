class Visio.Views.IndicatorSingleYearView extends Backbone.View

  template: JST['modules/indicator_single_year']

  initialize: (options) ->

  render: (isRerender) ->

    if !isRerender
      parameters = Visio.manager.selected(Visio.manager.get('aggregation_type')).sortBy (p) ->
        -p.selectedSituationAnalysis().result || 0
      @$el.html @template(
        parameters: parameters
      )


