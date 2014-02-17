class Visio.Figures.AbsyLegend extends Backbone.View

  className: 'legend'

  template: HAML['figures/absy_legend']

  initialize: ->

  render: ->
    @$el.html @template()
    @addAll()
    @

  addAll: =>
    @collection.each @addOne

  addOne: (model, idx) =>
    view = new Visio.Views.ParameterShowView
      model: model
      idx: idx

    $legendBody = @$el.find('.legend-body')
    $legendBody.append view.render().el

    if idx % 2 == 1
      $legendBody.append $('<div class="clearfix"></div>')


