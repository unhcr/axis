class Visio.Models.ExportModule extends Backbone.Model

  defaults:
    title: 'My Awesome New Visualization'
    description: 'Description'

    # Custom settings for the visualization
    state: {}

    # Whether or not to include the contributing parameters
    includeParameterList: false

    # Whether or not to include explanations of the algorithms
    includeExplaination: false

    # Data for exporting
    data: null

  figure: ->
    Visio.Figures[@get 'figureType']
