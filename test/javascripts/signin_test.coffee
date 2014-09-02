module 'Sign In',
  setup: ->
    sinon.stub $, 'post', ->
      return $.Deferred().resolve({ success: true }).promise()

    spy = sinon.spy Visio.Utils, 'signin'
    @view = new Visio.Views.SigninView()

    sinon.stub Visio.Views.SigninView.prototype, 'routeToHomepage', ->
      true
  teardown: ->
    $.post.restore()
    Visio.Utils.signin.restore()
    Visio.Views.SigninView.prototype.routeToHomepage.restore()

test 'render', ->
  strictEqual @view.$el.find('#login').length, 1
  strictEqual @view.$el.find('#password').length, 1

test 'signin w/o @unhcr.org', ->
  @view.$el.find('#login').val 'ben'
  @view.$el.find('#password').val 'rudolph'

  @view.$el.find('.signin').trigger 'click'

  ok $.post.calledOnce
  ok Visio.Views.SigninView.prototype.routeToHomepage.calledOnce
  ok Visio.Utils.signin.calledWith('ben', 'rudolph')


test 'signin w/ @unhcr.org', ->
  @view.$el.find('#login').val 'ben@unhcr.org'
  @view.$el.find('#password').val 'rudolph'

  @view.$el.find('.signin').trigger 'click'

  ok $.post.calledOnce
  ok Visio.Views.SigninView.prototype.routeToHomepage.calledOnce
  ok Visio.Utils.signin.calledWith('ben', 'rudolph')

test 'already signed in', ->
  Visio.user = new Visio.Models.User
    login: 'rudolph'

  view = new Visio.Views.SigninView()

  strictEqual view.$el.find('#login').length, 0
  strictEqual view.$el.find('#password').length, 0
