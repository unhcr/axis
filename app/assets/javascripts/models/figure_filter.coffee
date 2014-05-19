class Visio.Models.FigureFilter extends Backbone.Model
  initialize: ->
    @originalValues = _.clone @get('values')

  isFiltered: (datum) ->
    return false unless datum.get(@id)?

    not @get('values')[datum.get(@id)]

  filter: (name, active, opts = {}) ->
    return @get('values')[name] unless active?
    # Only one can be true for radio type
    if @get('filterType') == 'radio'
      _.each _.keys(@get('values')), (key) =>
        @get('values')[key] = false

    @get('values')[name] = active
    if @get('callback')? and not opts.silent
      @get('callback') name, active

  resetFilter: ->
    for name, active of @originalValues
      continue if @get('filterType') == 'radio' and not active
      if @get('values')[name] isnt active
        @get('callback') name, active if @get('callback')?

    @set 'values', _.clone(@originalValues)

  active: ->
    if @get('filterType') == 'radio'
      for name, active of @get('values')
        return name if active
    else if @get('filterType') == 'checkbox'
      actives = []
      for name, active of @get('values')
        actives.push name if active
      return actives
