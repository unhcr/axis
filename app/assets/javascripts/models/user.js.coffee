class Visio.Models.User extends Backbone.Model
  isLoggedIn: () ->
    !_.isEmpty(@.get('email'))

  urlRoot: '/users'

  paramRoot: 'user'

  defaults:
    'reset_local_db': false
