moduleKeywords = ['extended', 'included']
Backbone.View.extend = (obj) ->
  for key, value of obj when key not in moduleKeywords
      @[key] = value

    obj.extended?.apply(@)
    this

Backbone.View.include = (obj) ->
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      @::[key] = value

    obj.included?.apply(@)
    this

Backbone.Model.extend = (obj) ->
  for key, value of obj when key not in moduleKeywords
      @[key] = value

    obj.extended?.apply(@)
    this

Backbone.Model.include = (obj) ->
  for key, value of obj when key not in moduleKeywords
    # Assign properties to the prototype
    @::[key] = value

  obj.included?.apply(@)
  this

Backbone.Model::toJSON = ->
  json = _.clone(this.attributes)

  for attr, value of json
    if json[attr] instanceof Backbone.Model || json[attr] instanceof Backbone.Collection
      json[attr] = json[attr].toJSON()
  json
