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

    $.subscribe "select", @select
    @render()

  render: ->

    datum.index = i for datum, i in @model.get 'data'

    @$el.html @template( data: @model.get('data') )
    @config.selection = d3.select(@el).select('.export-figure figure')
    @figure = @model.figure()(@config)


    @figure.data @model.get('data')

    @figure()
    @

  onSelectionChange: (e) ->
    $target = $(e.currentTarget)
    d = _.find @model.get('data'), (d) ->
      d.index == +$target.val()

    $.publish "select.#{@model.get('figureType')}", [d]


  select: (e, d) =>
    $input = @$el.find("#datum-#{d.index}")
    checked = $input.is(':checked')

    # Toggle if it's check or not
    $input.prop 'checked', not checked

