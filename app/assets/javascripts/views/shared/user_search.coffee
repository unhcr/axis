class Visio.Views.UserSearch extends Backbone.View

  template: HAML['shared/user_search']

  resultTemplate: HAML['shared/users/result']

  initialize: ->
    @users = new Visio.Collections.User()

  events:
    'keyup input': 'onUserSearch'
    'click .user-search-result': 'onClickUserSearchResult'

  render: ->
    @$el.html @template()

  onUserSearch: (e) ->
    query = @$el.find('input').val()

    @search query

  search: (query) ->
    $results = @$el.find('.user-search-results')

    if not query? or query.length == 0
      $results.html ''
      return

    $.get('/users/search', { query: query }).done (results) =>
      @users.reset results
      $results.html ''

      _.each results, (result) =>
        $results.append @resultTemplate { user: result }

  onClickUserSearchResult: (e) ->

    $target = $(e.currentTarget)
    id = $target.attr('data-id')

    user = @users.get id


    @$el.find('.user-search-results').html ''
    @$el.find('input').val ''

    $.publish 'select.user', [user]





