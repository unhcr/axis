class Visio.Views.BmySummaryTooltip extends Visio.Views.BmyTooltip

  name: 'bmys'

  top: =>
    @figure.$el.find('svg:first').offset().top + @figure.yFn()(@model.get('amount'))
