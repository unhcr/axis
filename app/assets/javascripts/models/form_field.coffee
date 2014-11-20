class Visio.Models.FormField extends Backbone.Model

  setSelected: (ids) ->

    switch @get 'type'
      when 'collection'
        @set 'selected', ids
        @trigger 'fm-change:selected'

  getSelected: ->
    switch @get 'type'
      when 'collection'
        @get 'selected'

  selected: (id, value, silent = false) ->
    return _.include @get('selected'), id unless value?

    selected = _.without @get('selected'), id unless value

    selected = _.union @get('selected'), [id] if value

    @set 'selected', selected
    @trigger 'fm-change:selected' unless silent
