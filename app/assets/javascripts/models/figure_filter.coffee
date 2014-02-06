class Visio.Models.FigureFilter extends Backbone.Model

  isFiltered: (datum) ->
    return false unless datum.get(@id)?

    not @get('values')[datum.get(@id)]

  filter: (name, active) ->
    @get('values')[name] = active
