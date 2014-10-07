module 'Narratives',
  setup: ->
    @narratives = new Visio.Collections.Narrative(
      [{ id: 'abc', usertxt: 'ben' }, { id: 'def', usertxt: 'lisa' }])

test 'toHtmlText', ->

  strictEqual @narratives.toHtmlText(), 'ben<br />lisa'
