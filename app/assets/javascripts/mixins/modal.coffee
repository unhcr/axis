Visio.Mixins.Modal =
  initModal: ->
    @$el.addClass 'modal'

    $overlay = $('<div class="white-overlay"></div>')
    $body = $ 'body'
    $body.append $overlay
    $overlay.css 'height', $(document).height() + 'px'
    $(document).scrollTop 0

    previousClose = @close
    @close = ->
      $overlay.remove()
      previousClose.apply @, arguments
    @close.bind @

    $overlay.on 'click', (e) =>
      @close()
