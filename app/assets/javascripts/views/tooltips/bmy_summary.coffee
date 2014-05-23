class Visio.Views.BmySummaryTooltip extends Visio.Views.BmyTooltip

  name: 'bmy_summary'

  top: =>
    $(@figure.el).offset().top + @figure.yFn()(@model.get('amount'))
