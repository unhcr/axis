module 'Narrative Panel',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @selectedDatum = new Visio.SelectedData.Base({ d: new Visio.Models.Operation() })
    @panel = new Visio.Views.NarrativePanel()
    @panel.model = @selectedDatum
    $('#qunit-fixture').append '<div class="page"></div>'

    @server = sinon.fakeServer.create()
    narratives = [{ id: 'abc', usertxt: 'ben' }, { id: 'def', usertxt: 'lisa' }]
    @server.respondWith 'GET', /.*status.*/,
      [200, {'Content-Type': 'application/json'}, JSON.stringify({ success: true, token: 'token', complete: true, summary: 'my summary' })]

    @server.respondWith 'POST', /.*summarize.*/,
      [200, {'Content-Type': 'application/json'}, JSON.stringify({ success: true })]

    @server.respondWith 'POST', /narratives/,
      [200, {'Content-Type': 'application/json'}, JSON.stringify(narratives)]


  teardown: ->

    @server.restore()
    @panel.close()
    $('#qunit-fixture').empty()


test 'render', ->

  @panel.render()
  @server.respond()

  strictEqual @panel.$el.find('.panel-text').text().trim(), 'my summary'
  ok @panel.$el.find('.panel').size() > 0


test 'narratify-toggle-state', ->

  @panel.render()
  @server.respond()

  closeFilters = sinon.spy()

  $.subscribe 'close-filter-system', closeFilters

  $.publish 'narratify-toggle-state'

  ok @panel.isOpen()

  $.publish 'narratify-toggle-state'
  ok !@panel.isOpen()
  ok closeFilters.calledOnce

test 'narratify-close', ->

  @panel.render()
  @server.respond()

  $.publish 'narratify-toggle-state'
  $.publish 'narratify-close'

  ok !@panel.isOpen()

  $.publish 'narratify-close'
  ok !@panel.isOpen()

test 'renderTextType', ->

  @panel.render()
  @server.respond()

  @panel.renderTextType 'summary'
  @server.respond()
  strictEqual @panel.$el.find('.panel-text').text().trim(), 'my summary'

  @panel.renderTextType 'full_text'
  @server.respond()
  strictEqual @panel.$el.find('.panel-text').text().trim(), 'benlisa'
