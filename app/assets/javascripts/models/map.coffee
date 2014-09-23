class Visio.Models.Map extends Backbone.Model

  name: Visio.FigureTypes.MAP

  getMap: ->
    return $.Deferred().resolve(@get('map')).promise() if @get('map')

    unless Visio.manager?.get('use_local_db')
      return $.get('/map').done (record) =>
        @set('map', record)
        record

    db = Visio.manager.get 'db'

    $.when(db.get(Visio.Stores.MAP, Visio.mapMD5)).then((record) =>
      if !record
        return $.get('/map')
      else
        return record
    ).done((record) =>
      @set 'map', record
      db.put(Visio.Stores.MAP, record, Visio.mapMD5)
      record
    )

  toJSON: ->
    json = super

    # Map is way too big
    json.map = null
    json
