class Visio.Views.IndicatorSingleYearView extends Backbone.View

  template: JST['modules/indicator_single_year']

  initialize: (options) ->

  render: (isRerender) ->

    if !isRerender
      @$el.html @template(
        parameters: Visio.manager.selected(Visio.manager.get('aggregation_type'))
      )


