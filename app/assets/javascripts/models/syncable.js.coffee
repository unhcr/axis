class Visio.Models.Syncable extends Backbone.Model

  keyPath: 'id'

  toJSON: () ->
    json = _.clone(this.attributes)

    for attr, value of json
      if json[attr] instanceof Backbone.Model || json[attr] instanceof Backbone.Collection
        json[attr] = json[attr].toJSON()
    json

  toString: () ->
    return @get('name')

