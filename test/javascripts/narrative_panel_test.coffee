module 'Narrative Panel',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @selectedDatum = new Visio.SelectedData.Base({ d: new Visio.Models.Operation() })
    @panel = new Visio.Views.NarrativePanel()
    @panel.model = @selectedDatum
    $('#qunit-fixture').append '<div class="page"></div>'

    @server = sinon.fakeServer.create()
    narratives = [{ id: 'abc', usertxt: 'ben' }, { id: 'def', usertxt: 'lisa' }]
    results = [{ id: 'abc', highlight: { usertxt: ['a', 'b'] } },
                  { id: 'def', highlight: { usertxt: ['c', 'd'] } }]
    @server.respondWith 'GET', /.*status.*/,
      [200, {'Content-Type': 'application/json'}, JSON.stringify({ success: true, token: 'token', complete: true, summary: 'my summary' })]

    @server.respondWith 'POST', /.*summarize.*/,
      [200, {'Content-Type': 'application/json'}, JSON.stringify({ success: true })]

    @server.respondWith 'POST', /.*search.*/,
      [200, {'Content-Type': 'application/json'}, JSON.stringify(results)]

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

test 'renderTextType results', ->

  @panel.render()
  @server.respond()

  @panel.renderTextType 'results', { query: 'ben' }
  @server.respond()
  ok @panel.$el.find('.panel-text').text().indexOf('a') != -1
  ok @panel.$el.find('.panel-text').text().indexOf('b') != -1
  ok @panel.$el.find('.panel-text').text().indexOf('c') != -1
  ok @panel.$el.find('.panel-text').text().indexOf('d') != -1
  strictEqual @panel.$el.find('.panel-query').text().trim(), 'ben'
  strictEqual @panel.panels.length, 1
  panel = @panel.panels.at(0)
  ok panel.get('result')?
  strictEqual panel.get('result').get('query'), 'ben'
  strictEqual panel.get('result').get('page'), 0

  @panel.renderTextType 'summary'
  @server.respond()

  @panel.renderTextType 'results', { query: 'ben' }
  ok @panel.$el.find('.panel-text').text().indexOf('a') != -1
  ok @panel.$el.find('.panel-text').text().indexOf('b') != -1
  ok @panel.$el.find('.panel-text').text().indexOf('c') != -1
  ok @panel.$el.find('.panel-text').text().indexOf('d') != -1
  strictEqual @panel.$el.find('.panel-query').text().trim(), 'ben'
