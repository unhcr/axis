class Visio.Collections.Parameter extends Backbone.Collection

  model: Visio.Models.Parameter

  keyPath: 'id'

  limit: 1000

  store: () ->
    @name + '_store'

  setSynced: (parameters, timestampId) ->
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
         Visio.manager.setSyncDate(timestampId) if timestampId
      )
    else
      return req.done(() ->
        Visio.manager.setSyncDate(timestampId) if timestampId
      )

  getSynced: () ->
    db = Visio.manager.get('db')
    db.values(@store(), undefined, @limit)

  fetchSynced: (options, url) ->
    db = Visio.manager.get('db')
    options ||= {}

    url ||= @url

    timestampId = "#{url}#{JSON.stringify(options)}".hashCode()

    $.when(Visio.manager.getSyncDate(timestampId)).then((record) =>
      timestamp = if record then record.synced_timestamp else undefined
      options.synced_timestamp = timestamp
      return $.get(url, options)
    ).done((parameters) =>
      @setSynced(parameters, timestampId)
    ).done((ids) =>
      @getSynced()
    ).done((records) =>
      @reset(records)
    )

