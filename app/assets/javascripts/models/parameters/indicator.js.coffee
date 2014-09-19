class Visio.Models.Indicator extends Visio.Models.Parameter

  urlRoot: '/indicators'

  paramRoot: 'indicator'

  name: Visio.Parameters.INDICATORS

  isNumber: ->
    @get('indicator_type') == Visio.IndicatorTypes.NCNUMBER or
      @get('indicator_type') == Visio.IndicatorTypes.NUMBEROF

