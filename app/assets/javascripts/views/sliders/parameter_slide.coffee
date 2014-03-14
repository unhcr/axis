class Visio.Views.ParameterSlideView extends Visio.Views.Dashboard

  tagName: 'article'

  template: HAML['sliders/parameter_slide']

  initialize: (options) ->
    @template = HAML['pdf/sliders/parameter_slide'] if options.isPdf
    @idx = options.idx

    if options.isPdf
      @criticalityConfig.width = 34
      @criticalityConfig.height = 34
    else
      @criticalityConfig.width = 18
      @criticalityConfig.height = 18
    super options
    @parameter = @model

