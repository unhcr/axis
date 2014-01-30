class Visio.Views.D3Tooltip extends Backbone.View

  baseTemplate: JST['tooltips/base']

  className: 'd3-floating-tooltip'

  template: (data) ->
    @baseTemplate({ childTemplate: @childTemplate, data: data })

  width: -> '100px'

  top: -> 0

  left: -> 0

  initialize: ->
    @childTemplate = window.JST["tooltips/#{@name}"]
    @render()

  render: ->

    @$el.css 'top', @top() + 'px'
    @$el.css 'left', @left() + 'px'
    @$el.css 'width', @width()
    @$el.css 'height', @height()

    $('body').append @$el

  close: ->
    @unbind()
    @remove()
