module 'User',
  setup: ->
    @user = new Visio.Models.User
      login: 'ben'

test 'isLoggedIn', ->
  ok @user.isLoggedIn(), 'Should be logged in'

  @user.set 'login', null

  ok not @user.isLoggedIn(), 'Null should count as not logged in'

  @user.set 'login', ''
  ok @user.isLoggedIn(), 'empty should count as logged in'

