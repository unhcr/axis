class Visio.Collections.Parameter extends Backbone.Collection

  model: Visio.Models.Parameter

  keyPath: 'id'

  limit: 1000

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
      ).done(() ->
         Visio.manager.setSyncDate()
      )
    else
      return req.done(() ->
        Visio.manager.setSyncDate()
      )

  getSynced: () ->
    db = Visio.manager.get('db')
    db.values(@store(), undefined, @limit)

  fetchSynced: () ->
    db = Visio.manager.get('db')

    $.when(Visio.manager.getSyncDate()).then((record) =>
      date = if record then record.synced_timestamp else undefined
      console.log date
      return $.get(@url, synced_timestamp: date)
    ).done((response) =>
      parameters = response[@name]
      console.log parameters.new.length
      @setSynced(parameters)
    ).done((ids) =>
      @getSynced()
    ).done((records) =>
      @reset(records)
    )


