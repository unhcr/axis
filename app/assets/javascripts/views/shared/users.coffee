class Visio.Views.Users extends Backbone.View

  @include Visio.Mixins.Modal

  template: HAML['shared/list_users']

  rowTemplate: HAML['shared/users/list_row']

  className: 'admin-users-container'

  events:
    'click .cancel': 'close'
    'click .close-container .close': 'close'

  initialize: (options) ->
    @initModal()

    $.subscribe 'select.user', @onUserSelect
    @render()

  render: ->

    @$el.html @template()

    @userSearch = new Visio.Views.UserSearch({ el: @$el.find('.usersearch') })
    @userSearch.render()

    @collection.each (user) =>
      @$el.find('.userlist').append @rowTemplate({ user: user })


    @
  close: ->
    $.unsubscribe 'select.user'
    @unbind()
    @remove()
