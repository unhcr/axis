class Visio.Views.Users extends Backbone.View

  @include Visio.Mixins.Modal

  template: HAML['shared/list_users']

  rowTemplate: HAML['shared/users/list_row']

  className: 'admin-users-container'

  events:
    'click .user-pill .close' : 'onUserRemove'
    'click .close-container .close': 'close'
    'click .cancel': 'close'
    'click .submit': 'onSubmit'

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

  onUserRemove: (e) ->
    $pill = $(e.currentTarget).parent()

    id = $pill.attr 'data-id'

    $pill.remove()
    $pill.unbind()

    user = @collection.get id

    @collection.remove user

  onUserSelect: (e, user) =>
    if @collection.get(user.id)?
      $pill = @$el.find ".user#{Visio.Constants.SEPARATOR}#{user.id}"
      Visio.Utils.flash $pill
      return
    else if user.id == Visio.user.id
      (new Visio.Views.Error({ title: 'Cannot share with yourself!', description: 'You cannot share it with yourself' }))
      return

    @collection.add user

    @$el.find('.admin-users').append @pillTemplate({ user: user })

  onSubmit: (e) ->
    $target = $(e.currentTarget)
    return if $target.hasClass 'disabled'

    $target.addClass 'disabled'

    @submit().done ->
      $target.removeClass 'disabled'

  submit: ->
    $.ajax({
        type: 'POST'
        url: "/users/admin",
        data: JSON.stringify({ users: @collection.toJSON() || [] }),
        dataType: 'json',
        contentType: 'application/json'
      }).done((response) =>
        if response.success
          notification = new Visio.Views.Success
            title: 'Successfully created admin!'
            description: "You made #{@collection.length} people admins"
        else
          notification = new Visio.Views.Error
            title: 'Oops!'
            description: "Failed to create admin."
        @close()
      ).fail () ->
        notification = new Visio.Views.Error
          title: 'Oops!'
          description: "Failed to create admin."


  close: ->
    $.unsubscribe 'select.user'
    @unbind()
    @remove()
