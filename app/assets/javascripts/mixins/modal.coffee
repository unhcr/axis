Visio.Mixins.Modal =
  initModal: ->
    @$el.addClass 'modal'

    $overlay = $('<div class="white-overlay"></div>')
    $('body').append $overlay

    previousClose = @close
    @close = (save) ->
      $overlay.remove()
      previousClose(save)
    @close.bind @

    $overlay.on 'click', (e) =>
      @close()
