class Visio.Models.ExportModule extends Backbone.Model

  defaults:
    title: 'My Awesome New Visualization'
    description: 'Description'

    # Visualization function
    figure: null

    # Custom settings for the visualization
    settings: {}

    # Whether or not to include the contributing parameters
    includeParameterList: false

    # Whether or not to include explanations of the algorithms
    includeExplaination: false

    # Needs a way to get data
    data: null
