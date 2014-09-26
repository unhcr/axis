class Visio.Views.Module extends Backbone.View

  figureWidth: (hasLegend) ->

    width = $('#module').width()

    if hasLegend and !$('.page').hasClass('shift') and !$('.page').hasClass('shift-right')
      width -= (Visio.Constants.LEGEND_WIDTH + 40)

    width

  close: ->
    @figure?.close()
    @unbind()
    @remove()
