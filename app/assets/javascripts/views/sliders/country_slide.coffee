class Visio.Views.CountrySlideView extends Visio.Views.Dashboard

  template: HAML['sliders/country_slide']

  initialize: (options) ->
    @criticalityConfig.width = 18
    @criticalityConfig.height = 18
    super options
    @parameter = @model

