class Visio.Figures.IcmyLegend extends Backbone.View

  className: 'legend'

  template: HAML['pdf/figures/icmy_legend']

  initialize: (options) ->
    @figure = options.figure
    @selected = options.selected
    switch @figure.filters.get('algorithm').active()
      when 'selectedOutputAchievement'
        @legendType = Visio.FigureTypes.OASY
        @keys = Visio.Algorithms.THRESHOLDS
      when 'selectedAchievement'
        @legendType = Visio.FigureTypes.PASY
        @keys = Visio.Algorithms.THRESHOLDS
      when 'selectedSituationAnalysis'
        @legendType = Visio.FigureTypes.ICSY
        @keys = Visio.Algorithms.CRITICALITIES

  render: ->
    @$el.html @template
      keys: @keys
    @addAll()
    @

  addAll: =>
    _.each @selected, @addOne

  addOne: (year, idx) =>

    view = new Visio.Views.IcmyLegendShowView
      filters: @figure.filters
      year: year
      collection: @collection
      type: @legendType
      idx: idx

    $legendBody = @$el.find '.legend-body'
    $legendBody.append view.render().el
