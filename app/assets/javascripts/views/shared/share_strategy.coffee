class Visio.Views.ShareStrategy extends Backbone.View

  @include Visio.Mixins.Modal

  template: HAML['shared/share_strategy']

  pillTemplate: HAML['shared/users/pill']

  className: 'share-strategy-container'

  events:
    'click .user-pill .close' : 'onUserRemove'
    'click .close-container .close': 'close'
    'click .cancel': 'close'
    'click .share': 'onShare'

  initialize: (options) ->
    @strategy = options.strategy
    @initModal()

    $.subscribe 'select.user', @onUserSelect

  render: ->

    @$el.html @template
      strategy: @strategy

    @userSearch = new Visio.Views.UserSearch({ el: @$el.find('.usersearch') })
    @userSearch.render()

    @collection.each (user) =>
      @$el.find('.shared-users').append @pillTemplate({ user: user })


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

    @$el.find('.shared-users').append @pillTemplate({ user: user })

  onShare: (e) ->
    $target = $(e.currentTarget)
    return if $target.hasClass 'disabled'

    $target.addClass 'disabled'

    @share().done ->
      $target.removeClass 'disabled'

  share: ->
    $.ajax(
      {
        type: 'POST'
        url: "/users/#{Visio.user.id}/share/#{Visio.manager.get('dashboard').id}",
        data: JSON.stringify({ users: @collection.toJSON() }),
        dataType: 'json',
        contentType: 'application/json'
      }).done((response) =>
        if response.success
          notification = new Visio.Views.Success
            title: 'Successfully shared!'
            description: "You shared your strategy with #{@collection.length} people"
        else
          notification = new Visio.Views.Error
            title: 'Oops!'
            description: "Failed to share strategy."
        @close()
      ).fail () ->
        notification = new Visio.Views.Error
          title: 'Oops!'
          description: "Failed to share strategy."


  close: ->
    @unbind()
    @remove()
