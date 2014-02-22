class Visio.Views.AccordionShowView extends Backbone.View

  isOpen: =>
    @$el.hasClass 'open'

  expand: =>
    @$el.addClass 'open'

  shrink: =>
    @$el.removeClass 'open'

  toolbarHeight: => $('.toolbar').height() + 20


  onTransitionEnd: (e) ->
    if @isOpen() and e.originalEvent.propertyName == 'max-height'
      $.scrollTo @$el,
        duration: 100
        offset:
          top: -@toolbarHeight()
          left: 0
  close: ->
    @removeInstances()
    @unbind()
    @remove()

  onClickParameter: (e) ->

    $('.accordion-show-container').not(@$el).removeClass 'open'
    @$el.toggleClass 'open'

    @drawFigures() if @isOpen()
