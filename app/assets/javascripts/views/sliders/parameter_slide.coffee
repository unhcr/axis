class Visio.Views.ParameterSlideView extends Visio.Views.Dashboard

  tagName: 'article'

  template: HAML['sliders/parameter_slide']

  initialize: (options) ->
    @template = HAML['pdf/sliders/parameter_slide'] if options.isPdf
    @idx = options.idx

    if options.isPdf
      @criticalityConfig.width = 60
      @criticalityConfig.height = 30
    else
      @criticalityConfig.width = 60
      @criticalityConfig.height = 30
    super options
    @parameter = @model

