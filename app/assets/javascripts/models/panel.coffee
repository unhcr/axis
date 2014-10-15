class Visio.Models.Panel extends Backbone.Model

  defaults:
    page: 1
    full_text: ''

    # This should be true if all narratives have been loaded for the panel
    loaded: false

  initialize: ->
    @set 'narratives', new Visio.Collections.Narrative()
