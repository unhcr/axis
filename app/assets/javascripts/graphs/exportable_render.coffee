Visio.Figures.exportableRender = {}
Visio.Figures.exportableRender.unsubscribe = ->
  $.unsubscribe "select.#{figureId}.figure"

Visio.Figures.exportableRender.exportId = ->
  return figureId + '_export'

Visio.Figures.exportableRender.filterFn = (d) ->
  return d.selectedAmount() && d.selectedAchievement().result

Visio.Figures.exportableRender.el = () ->
  return selection.node()

Visio.Figures.exportableRender.sortFn = (a, b) -> 0


