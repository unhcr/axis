class Visio.Models.IndicatorDatum extends Backbone.Model

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/indicator_data'

  paramRoot: 'indicator_datum'

  situation_analysis: (reported_value) ->
    reported_value ||= 'myr'
    if @get(reported_value) >= @get('threshold_green')
      return Visio.Algorithms.ALGO_COLORS.success
    else if @get(reported_value) >= @get('threshold_red')
      return Visio.Algorithms.ALGO_COLORS.ok
    else
      return Visio.Algorithms.ALGO_COLORS.fail





