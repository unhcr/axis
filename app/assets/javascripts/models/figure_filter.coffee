class Visio.Models.FigureFilter extends Backbone.Model
  initialize: ->
    @originalValues = _.clone @get('values')

  isFiltered: (datum) ->
    return false unless datum.get(@id)?

    not @get('values')[datum.get(@id)]

  filter: (name, active) ->
    return @get('values')[name] unless active?
    # Only one can be true for radio type
    if @get('filterType') == 'radio'
      _.each _.keys(@get('values')), (key) =>
        @get('values')[key] = false

    @get('values')[name] = active
    if @get('callback')?
      @get('callback') name, active

  resetFilter: ->
    for name, active of @originalValues
      continue if @get('filterType') == 'radio' and not active
      if @get('values')[name] isnt active
        @get('callback') name, active if @get('callback')?

    @set 'values', _.clone(@originalValues)
