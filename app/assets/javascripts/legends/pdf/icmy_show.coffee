class Visio.Legends.IcmyShowPdf extends Backbone.View

  tagName: 'article'

  className: 'icmy-legend-show pbi-avoid'

  template: HAML['pdf/figures/icmy_legend_show']

  initialize: (options) ->
    @idx = options.idx
    @filters = options.filters
    @type = options.type
    height = 170
    @config =
      width: 72
      height: height
      orientation: 'bottom'
      hasLabels: true
      margin:
        top: 20
        bottom: 0
        left: 2
        right: 2
    @year = if options.year then +options.year else null

    @figure = new Visio.Figures[@type.className] _.clone(@config)

    @axis = new Visio.Figures.Axis
      margin:
        top: 20
        bottom: 10
        left: 70
      width: 70
      height: height

    switch @type.name
      when Visio.FigureTypes.ICSY.name
        result = @collection.selectedSituationAnalysis @year, @filters
      when Visio.FigureTypes.PASY.name
        result = @collection.selectedAchievement @year, @filters
      when Visio.FigureTypes.OASY.name
        result = @collection.selectedOutputAchievement @year, @filters
      else
        console.error 'Invalid Figure type'

    @figure.modelFn new Backbone.Model(result)

  render: ->
    @$el.html @template
      year: @year
      idx: @idx
      type: @type

    @$el.find('figure').html @figure.render().el
    @$el.find('.bar-axis').html @axis.render().el
    @

