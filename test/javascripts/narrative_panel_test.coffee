module 'Narrative Panel',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @selectedDatum = new Visio.SelectedData.Base({ d: new Visio.Models.Operation() })
    @panel = new Visio.Views.NarrativePanel()
    $('#qunit-fixture').append '<div class="page"></div>'

  teardown: ->
    @panel.close()
    $('#qunit-fixture').empty()


test 'render', ->

  @panel.render()

  ok @panel.$el.find('.panel').size() > 0

test 'narratify-toggle-state', ->

  @panel.render()

  closeFilters = sinon.spy()

  $.subscribe 'close-filter-system', closeFilters

  $.publish 'narratify-toggle-state'

  ok @panel.isOpen()

  $.publish 'narratify-toggle-state'
  ok !@panel.isOpen()
  ok closeFilters.calledOnce

test 'narratify-close', ->

  @panel.render()

  $.publish 'narratify-toggle-state'
  $.publish 'narratify-close'

  ok !@panel.isOpen()

  $.publish 'narratify-close'
  ok !@panel.isOpen()

test 'onDownload', ->

  stub = sinon.stub Visio.Utils, 'redirect'

  @panel.render()

  @panel.model = @selectedDatum

  @panel.onDownload()

  ok stub.calledOnce
  ok stub.calledWithMatch('name')
  ok stub.calledWithMatch('filter_ids')
  ok stub.calledWithMatch('year')
  ok stub.calledWithMatch('report_type')
  ok stub.calledWithMatch('USERTXT')
