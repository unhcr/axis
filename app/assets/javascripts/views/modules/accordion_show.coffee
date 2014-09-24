class Visio.Views.AccordionShowView extends Visio.Views.Module

  @include Visio.Mixins.Narratify

  isOpen: =>
    @$el.hasClass 'open'

  expand: =>
    @$el.addClass 'open'

  shrink: =>
    @$el.removeClass 'open'

  toolbarHeight: => $('#header').height()


  onParameterTransitionEnd: (e) ->
    e.stopPropagation()
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
