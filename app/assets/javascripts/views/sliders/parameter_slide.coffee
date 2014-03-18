class Visio.Views.ParameterSlideView extends Visio.Views.Dashboard

  tagName: 'article'

  template: HAML['sliders/parameter_slide']

  initialize: (options) ->
    @template = HAML['pdf/sliders/parameter_slide'] if options.isPdf
    @idx = options.idx

    if options.isPdf
      @criticalityConfig.width = 100
      @criticalityConfig.height = 20

      @achievementConfig.width = 100
      @achievementConfig.height = 20

      @outputAchievementConfig.width = 100
      @outputAchievementConfig.height = 20
    else
      @criticalityConfig.width = 100
      @criticalityConfig.height = 20

      @achievementConfig.width = 100
      @achievementConfig.height = 20

      @outputAchievementConfig.width = 100
      @outputAchievementConfig.height = 20
    super options
    @parameter = @model

