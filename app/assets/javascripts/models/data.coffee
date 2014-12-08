class Visio.Models.Data extends Backbone.Model

  toString: () ->
    return @get('name')

