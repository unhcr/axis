class Visio.Views.ExportModule extends Backbone.View

  className: 'overview-overlay'

  template: JST['shared/export_module']

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

    @render()

  render: ->
    @$el.html @template()

    @config.selection = d3.select(@el).select('.export-figure')
    @figure = @model.get('figure')(@config)
    @figure.data @model.get('data')

    @figure()
    @

