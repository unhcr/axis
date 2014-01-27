class Visio.Views.ExportModule extends Backbone.View

  className: 'overview-overlay'

  template: JST['shared/export_module']

  events:
    'change figcaption input': 'onSelectionChange'

  initialize: (options) ->
    $(document).scrollTop(0)

    @config =
      margin:
        top: 30
        bottom: 30
        left: 90
        right: 80
      width: 600
      height: 300
      isExport: true

    $.subscribe "#{@model.get('figureType')}.select", @select
    @render()

  render: ->

    i = 0
    for datum in @model.get 'data'
      if Visio.Figures[@model.get('figureType')].filterFn datum
        datum.index = i
        i += 1

    @$el.html @template( data: @model.get('data') )
    @config.selection = d3.select(@el).select('.export-figure figure')
    @figure = @model.get('figure')(@config)


    @figure.data @model.get('data')

    @figure()
    @

  onSelectionChange: (e) ->
    $target = $(e.currentTarget)
    d = _.find @model.get('data'), (d) ->
      d.index == +$target.val()

    $.publish "#{@model.get('figureType')}.select", [d.toJSON()]


  select: (e, d) =>
    $input = @$el.find("#datum-#{d.index}")
    checked = $input.is(':checked')

    # Toggle if it's check or not
    $input.prop 'checked', not checked

