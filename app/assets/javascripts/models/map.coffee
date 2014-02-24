class Visio.Models.Map extends Backbone.Model

  getMap: ->
    unless Visio.manager?.get('use_local_db')
      return $.get('/map').done (record) => @set('map', record)

    db = Visio.manager.get 'db'

    $.when(db.get(Visio.Stores.MAP, @get('mapMD5'))).then((record) =>
      if !record
        return $.get('/map')
      else
        return record
    ).done((record) =>
      @set 'map', record
      db.put(Visio.Stores.MAP, record, @get('mapMD5'))
    )
