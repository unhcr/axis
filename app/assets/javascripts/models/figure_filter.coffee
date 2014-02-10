class Visio.Models.FigureFilter extends Backbone.Model

  isFiltered: (datum) ->
    return false unless datum.get(@id)?

    not @get('values')[datum.get(@id)]

  filter: (name, active) ->
    # Only one can be true for radio type
    if @get('filterType') == 'radio'
      _.each _.keys(@get('values')), (key) =>
        @get('values')[key] = false

    @get('values')[name] = active
    if @get('callback')?
      @get('callback') name, active

  resetFilter: ->
    _.each _.keys(@get('values')), (key) =>
      @get('values')[key] = true


