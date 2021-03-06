class Visio.Legends.IcmyPdf extends Backbone.View

  className: 'legend'

  template: HAML['pdf/figures/icmy_legend']

  initialize: (options) ->
    @figure = options.figure
    @collection = options.figure.collection
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
    years = Visio.manager.get('yearList').filter (year) -> year <= (new Date()).getFullYear()
    _.each years, @addOne

  addOne: (year, idx) =>

    view = new Visio.Legends.IcmyShowPdf
      filters: @figure.filters
      year: year
      collection: @collection
      type: @legendType
      idx: idx

    $legendBody = @$el.find '.legend-body'
    $legendBody.append view.render().el

