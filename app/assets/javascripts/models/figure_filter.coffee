class Visio.Models.FigureFilter extends Backbone.Model

  isFiltered: (name) ->
    @get('values')[name]

  filter: (name, active) ->
    @get('values')[name] = active
