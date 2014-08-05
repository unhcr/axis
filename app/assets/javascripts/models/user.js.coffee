class Visio.Models.User extends Backbone.Model
  isLoggedIn: () ->
    @get('login')?

  urlRoot: '/users'

  paramRoot: 'user'

  defaults:
    'reset_local_db': false

  toString: ->
    @get 'login'
