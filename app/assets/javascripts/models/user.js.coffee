class Visio.Models.User extends Backbone.Model
  isLoggedIn: () ->
    !_.isEmpty(@.get('login'))

  urlRoot: '/users'

  paramRoot: 'user'

  defaults:
    'reset_local_db': false
