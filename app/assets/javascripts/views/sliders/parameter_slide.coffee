class Visio.Views.ParameterSlideView extends Visio.Views.Dashboard

  tagName: 'article'

  template: HAML['sliders/parameter_slide']

  initialize: (options) ->
    @template = HAML['pdf/sliders/parameter_slide'] if options.isPdf
    @idx = options.idx
    @barConfig.orientation = 'left'
    @isPdf = options.isPdf

    if @isPdf
      @barConfig.width = 250
      @barConfig.height = 56
      @barConfig.hasLabels = true
    else
      @barConfig.width = 150
      @barConfig.height = 30

    super options
    @parameter = @model

