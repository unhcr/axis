class Visio.Views.BmySummaryTooltip extends Visio.Views.BmyTooltip

  name: 'bmys'

  top: =>
    $(@figure.el).offset().top + @figure.yFn()(@model.get('amount'))
