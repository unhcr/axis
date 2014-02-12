class Visio.Views.CountrySlideView extends Visio.Views.Dashboard

  template: HAML['sliders/country_slide']

  initialize: (options) ->
    @criticalityConfig.width = 16
    @criticalityConfig.height = 16
    Visio.Views.Dashboard.prototype.initialize.call @, options
    @parameter = @model

