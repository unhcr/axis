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

