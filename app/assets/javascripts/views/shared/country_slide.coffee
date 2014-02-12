class Visio.Views.CountrySlideView extends Visio.Views.Dashboard

  className: 'country-slide'

  template: HAML['shared/country_slide']

  initialize: (options) ->
    @criticalityConfig.width = 16
    @criticalityConfig.height = 16
    Visio.Views.Dashboard.prototype.initialize.call @, options
    @parameter = @model

