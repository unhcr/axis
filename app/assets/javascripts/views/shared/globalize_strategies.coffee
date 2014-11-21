class Visio.Views.GlobalizeStrategies extends Backbone.View

  @include Visio.Mixins.Modal

  template: HAML['shared/globalize_strategies']

  className: 'globalize-strategies-container'

  events:
    'click .close-container .close': 'close'
    'click .cancel': 'close'
    'click .globalize': 'onGlobalize'

  initialize: (options) ->
    @initModal()

    @render()

  render: =>

    @$el.html @template
      strategies: @collection

    @

  onGlobalize: (e) ->
    $target = $(e.currentTarget)
    id = $target.data().id
    strategy = @collection.get id
    $target.addClass 'disabled'

    if window.confirm("Are you sure you want to globalize #{strategy.toString()}? This will make the strategy viewable to everyone.")
      @globalize(strategy).done ->
        $target.removeClass 'disabled'


  globalize: (strategy) ->
    NProgress.start()
    $.ajax({
      type: 'POST'
      url: "/strategies/#{strategy.id}/globalize"
      dataType: 'json',
      contentType: 'application/json'
    }).done((response) =>
      NProgress.done()
      if response.success
        @collection.add response.strategy, { merge: true }
        notification = new Visio.Views.Success
          title: "Success!"
          description: "You made #{strategy.toString()} a global strategy"
        @$el.find(".btn[data-id=\"#{strategy.id}\"]").replaceWith('Globalized!')
      else
        notification = new Visio.Views.Error
          title: 'Oops!'
          description: "Failed to make it a global strategy"
    ).fail ()->
        notification = new Visio.Views.Error
          title: 'Oops!'
          description: "Failed to make it a global strategy"


  close: ->
    $.unsubscribe 'select.user'
    @unbind()
    @remove()

