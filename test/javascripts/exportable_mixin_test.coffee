module 'Exportable',
  setup: ->
    class TestView extends Backbone.View
      @include Visio.Mixins.Exportable

    @view = new TestView()

test 'config', ->
  config = @view.config()

  ok not config.collection
  ok not config.model
  ok not config.type
  ok not config.selectable

  @view.collection = new Visio.Collections.Operation([])
  @view.model = new Visio.Models.Ppg([])

  config = @view.config()

  ok config.collection
  ok config.collectionName
  ok config.model
  ok config.modelName

  ok not config.type
  ok not config.selectable

  @view.attrConfig = ['blue', 'green']
  @view.blue = 'howdy'
  @view.green = 'hello'

  config = @view.config()

  strictEqual @view.blue, 'howdy'
  strictEqual @view.green, 'hello'
