class Visio.Legends.AbsyPdf extends Visio.Legends.Base

  isPdf: true

  type: Visio.FigureTypes.ABSY

  initialize: (options = {}) ->
    super
    @figure = options.figure

  render: ->
    @$el.html @template()
    @addAll()
    @

  addAll: =>
    @figure.activeData.each @addOne

  addOne: (model, idx) =>
    view = new Visio.Views.ParameterShowView
      filters: @figure.filters
      model: model.get('d')
      idx: idx

    $legendBody = @$el.find('.legend-body')
    $legendBody.append view.render().el
