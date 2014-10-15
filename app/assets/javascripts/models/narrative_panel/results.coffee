class Visio.Models.NarrativeSearchResult extends Backbone.Model

  defaults:
    query: ''
    results: []
    page: 1
    loaded: false

  toHtmlText: ->

    html = ''

    _.each @get('results'), (result) ->
      _.each (result.highlight?.usertxt), (highlight) ->
        html += '<p>...'
        html += highlight.replace(/\\n/g, '<br />')
        html += '...</p>'

    html
