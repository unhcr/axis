class Visio.Models.Parameter extends Backbone.Model

  store: () ->
    @name + '_store'

  keyPath: 'id'

  setSynced: () ->
    db = Visio.manager.get('db')
    db.put({
      name: @store()
      keyPath: @keyPath }, @toJSON())

  getSynced: () ->
    db = Visio.manager.get('db')
    db.get(@store(), @id)

  toJSON: () ->
    json = _.clone(this.attributes)

    for attr, value of json
      if json[attr] instanceof Backbone.Model || json[attr] instanceof Backbone.Collection
        json[attr] = json[attr].toJSON()
    json

