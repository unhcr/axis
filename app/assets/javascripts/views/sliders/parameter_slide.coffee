class Visio.Views.ParameterSlideView extends Visio.Views.Dashboard

  tagName: 'article'

  template: HAML['sliders/parameter_slide']

  initialize: (options) ->
    @template = HAML['pdf/sliders/parameter_slide'] if options.isPdf
    @idx = options.idx
    @barConfig.orientation = 'left'

    if options.isPdf
      @barConfig.width = 250
      @barConfig.height = 56
      @barConfig.hasLabels = true
    else
      @barConfig.width = 100
      @barConfig.height = 20

    super options
    @parameter = @model

