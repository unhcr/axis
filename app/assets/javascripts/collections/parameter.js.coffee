class Visio.Collections.Parameter extends Backbone.Collection

  model: Visio.Models.Parameter

  keyPath: 'id'

  store: () ->
    @name + '_store'

  setSynced: (parameters) ->
    db = Visio.manager.get('db')
    req = db.put({
      name: @store()
      keyPath: @keyPath }, parameters.new.concat(parameters.updated))

    if parameters.deleted.length > 0
      req.done((ids) =>
        # Remove deleted plans
        req = null
        _.each(parameters.deleted, (parameter) =>
          req = db.remove(@store(), parameter.id)
        )
        return req
      )
    else
      return req

  getSynced: () ->
    db = Visio.manager.get('db')
    db.values(@store())

  fetchSynced: (options) ->
    db = Visio.manager.get('db')

    Visio.manager.getSyncDate().done((record) =>
      return @fetch(synced_date: record.synced_date)
    ).done((response) =>
      return @setSynced(response[@name])
    ).done(() ->
      return db.values(@store)
    )
