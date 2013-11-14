class Visio.Routers.SplashRouter extends Backbone.Router

  initialize: () ->
    console.log 'starting'

  routes: () ->
    'signin': 'signin'
    'signup': 'signup'
    '*default': 'signin'

  signin: () ->

  signup: () ->

