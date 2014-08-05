class Visio.Views.ParameterSlideView extends Visio.Views.Dashboard

  tagName: 'article'

  template: HAML['sliders/parameter_slide']

  selectedBarFigure: Visio.FigureTypes.OASY

  events:
    'change .ui-tab-radio input': 'onTabChange'

  initialize: (options) ->
    @template = HAML['pdf/sliders/parameter_slide'] if options.isPdf
    @idx = options.idx
    @barConfig.orientation = 'left'
    @isPdf = options.isPdf
    @barConfig.hasLabels = true
    @barConfig.hasZeroPad = true

    if @isPdf
      @barConfig.width = 250
      @barConfig.height = 115
    else
      @barConfig.width = 240
      @barConfig.height = 130

    super options
    @parameter = @model

  onTabChange: (e) ->
    figureName = $(e.currentTarget).val()
    @$el.find('.bar-figure').addClass('gone')
    @$el.find(".#{figureName}-figure-#{@cid}").removeClass('gone')
