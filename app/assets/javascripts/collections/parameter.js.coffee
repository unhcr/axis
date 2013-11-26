class Visio.Collections.Parameter extends Backbone.Collection

  model: Visio.Models.Parameter

  keyPath: 'id'

  limit: 1000

  store: () ->
    @name + '_store'

  setSynced: (parameters, resetSyncDate) ->
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
      ).done(() ->
         Visio.manager.setSyncDate() if resetSyncDate
      )
    else
      return req.done(() ->
        Visio.manager.setSyncDate() if resetSyncDate
      )

  getSynced: () ->
    db = Visio.manager.get('db')
    db.values(@store(), undefined, @limit)

  fetchSynced: () ->
    db = Visio.manager.get('db')

    $.when(Visio.manager.getSyncDate()).then((record) =>
      timestamp = if record then record.synced_timestamp else undefined
      return $.get(@url, synced_timestamp: timestamp)
    ).done((parameters) =>
      @setSynced(parameters, true)
    ).done((ids) =>
      @getSynced()
    ).done((records) =>
      @reset(records)
    )

