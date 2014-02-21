class Visio.Models.ExportModule extends Backbone.Model

  defaults:
    title: 'My Awesome New Visualization'
    description: 'Description'

    # Custom settings for the visualization
    state: {}

    # Whether or not to include the contributing parameters
    include_parameter_list: false

    # Whether or not to include explanations of the algorithms
    include_explaination: false

    # Data for exporting
    data: null

  initialize: (options) ->
    if options?.figure_config?.collection
      options.figure_config.collection =
        new Visio.Collections[options.figure_config.collectionName](options.figure_config.collection)
    if options?.figure_config?.model
      options.figure_config.model =
        new Visio.Models[options.figure_config.modelName](options.figure_config.model)


  figure: (config) ->
    new Visio[config.viewLocation][@get('figure_type').className](config)


  figure_config: {}

  urlRoot: '/export_modules'

  pdfUrl: ->
    "#{@urlRoot}/#{@id}/pdf.pdf"

  paramRoot: 'export_module'
