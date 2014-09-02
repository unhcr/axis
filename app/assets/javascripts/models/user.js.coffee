class Visio.Models.User extends Backbone.Model
  isLoggedIn: () ->
    @get('login')?

  isAdmin: ->
    if @get('admin')? then @get('admin') else false

  urlRoot: '/users'

  paramRoot: 'user'

  defaults:
    'reset_local_db': false

  toString: ->
    @get 'login'
