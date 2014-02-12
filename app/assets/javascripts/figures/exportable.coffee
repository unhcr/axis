class Visio.Figures.Exportable extends Visio.Figures.Base

  attrConfig: ['margin', 'data', 'width', 'height']

  initialize: (config) ->
    super config



    $.subscribe "select.#{@cid}.figure", @select

  config: =>
    config = {}

    _.each @attrConfig, (attr) =>
      config[attr] = @[attr]

    config.height = @originalHeight
    config.width = @originalWidth

    config

  unsubscribe: => $.unsubscribe "select.#{@cid}.figure"

  select: (e, d, i) -> console.error('No select implemented')

  filtered: (data) -> data

  figureId: -> @cid
