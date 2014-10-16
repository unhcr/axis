class Visio.Views.NarrativePanel extends Backbone.View

  template: HAML['shared/narrative_panel']

  textTypes:
    summary:
      name: 'summary'
      human: 'Summary'
      template: HAML['shared/narrative_panels/summary']
    full_text:
      name: 'full_text'
      human: 'Full Text'
      template: HAML['shared/narrative_panels/full_text']
    results:
      name: 'results'
      human: 'Search Results'
      template: HAML['shared/narrative_panels/results']

  textType: 'summary'

  timeout: 2000 # 2 seconds

  initialize: ->
    @panels = new Visio.Collections.Panel

    $.subscribe 'narratify-toggle-state', @onNarratifyStateToggle
    $.subscribe 'narratify-close', @onNarratifyClose
    $.subscribe 'narratify', @onNarratify
    $.subscribe 'narratify-scroll.bottom', @onScrollBottom

  events:
    'click .export': 'onDownload'
    'click .close': 'onNarratifyClose'
    'change .ui-tab-radio input': 'onChangeTextType'
    'keyup .query-by input': 'onQuery'
    'focus .query-by input': 'onFocus'
    'blur .query-by input': 'onBlur'

  render: ->

    @$el.html @template
      model: @model
      textTypes: @textTypes
      textType: @textType
    @renderTextType @textType
    @


  renderTextType: (textTypeName, opts = {}) ->
    textType = @textTypes[textTypeName]

    @$el.find('.panel-text').html textType.template
      model: @model

    if textType == @textTypes.full_text or textType == @textTypes.results
      @$el.find('.panel-text').on 'scroll', @onScroll

    summaryParameters = @model.summaryParameters()

    panelId = @getPanelId summaryParameters
    panel = @panels.get panelId
    $panel = @$el.find(".panel .panel-#{textType.name}-#{@model.cid}")

    if panel
      if textType == @textTypes.summary and panel.get(textType.name)
        $panel.text panel.get(textType.name)
        return
      else if textType == @textTypes.full_text and panel.get('narratives').length
        $panel.html panel.get('narratives').toHtmlText()
        return
      # Render cached results if same query or there is no query
      else if textType == @textTypes.results and panel.get('result') and (not opts.query? or
          (panel.get('result').get('query').length and
          panel.get('result').get('query') == opts.query))

        @$el.find(".panel .panel-#{textType.name}-query-#{@model.cid}").text panel.get('result').get('query')
        $panel.html panel.get('result').toHtmlText()
        return

    if not panel
      panel = new Visio.Models.Panel
        id: panelId
      @panels.add panel

    switch textType.name
      when @textTypes.summary.name
        @summarize(summaryParameters).done (resp) => @doneSummarize(resp, panel)
      when @textTypes.results.name
        if opts.query?
          return if panel.get('result')?.get('loaded') and opts.query == panel.get('result').get('query')
          NProgress.start()
          @search(opts.query, 0).done (resp) =>
            @doneSearch(resp, panel, $panel, opts.query)
            NProgress.done()

      when @textTypes.full_text.name
        return if panel.get 'loaded'
        NProgress.start()
        @fetchText(panel.get('page'), summaryParameters).done (resp) =>
          @doneText(resp, panel, $panel)
          NProgress.done()

  doneText: (resp, panel, $panel) ->
    if !resp or resp.length == 0
      panel.set 'loaded', true

    narratives = new Visio.Collections.Narrative(resp)
    panel.get('narratives').add narratives.models
    panel.set 'page', panel.get('page') + 1

    $panel.append narratives.toHtmlText()

  doneSummarize: (resp, panel) =>
    if resp.success
      @fetchSummary resp.token, panel, @timeout

  doneSearch: (resp, panel, $panel, query) =>
    result = panel.get 'result'

    if result? and result.get('query') == query
      result.set 'page', result.get('page') + 1
    else
      result = new Visio.Models.NarrativeSearchResult
        results: resp
        query: query
      panel.set 'result', result

    if !resp or resp.length == 0
      result.set 'loaded', true

    @$el.find(".panel .panel-#{@textTypes.results.name}-query-#{@model.cid}").text query
    $panel.html result.toHtmlText()

  search: (query, page = 0) =>
    params = @model.summaryParameters()

    options =
      query: query
      filter_ids: params.ids
      year: params.year
      report_type: Visio.Utils.dbMetric(params.reported_type)
      page: page

    $.post('/narratives/search', options)

  getPanelId: (summaryParameters) ->
    JSON.stringify(summaryParameters).hashCode()

  openClass: 'shift-right'

  onChangeTextType: (e) =>
    @textType = $(e.currentTarget).val()

    @renderTextType @textType


  onNarratifyStateToggle: (e) =>
    $('.page').toggleClass @openClass
    $('.header-buttons .narrative').toggleClass 'open'

    $.publish 'close-filter-system' if @isOpen()

  onNarratifyClose: (e) =>
    $('.page').removeClass @openClass
    $('.header-buttons .narrative').removeClass 'open'

  onDownload: (e) =>
    e.stopPropagation()
    $form = @$el.find('#download-form')
    $form.submit()

  onNarratify: (e, selectedDatum) =>
    @model = selectedDatum
    @render()

  onFullTextScroll: (panel, $panel) =>
    return if @loadingFullText

    summaryParameters = @model.summaryParameters()
    @loadingFullText = true
    @fetchText(panel.get('page'), summaryParameters).done (resp) =>
      @loadingFullText = false
      @doneText(resp, panel, $panel)

  onResultsScroll: (panel, $panel) =>
    return if @loadingResults
    result = panel.get 'result'
    @loadingResults = true
    @search(result.get('query'), result.get('page')).done (resp) =>
      @loadingResults = false
      @doneSearch(resp, panel, $panel, result.get('query'))


  onScroll: (e) =>
    fn = =>
      $panel = $(e.currentTarget)

      scrollTop = $panel.scrollTop()
      scrollHeight = $panel[0].scrollHeight

      bottomOffset = 300

      if scrollTop + $panel.height() + bottomOffset > scrollHeight
        summaryParameters = @model.summaryParameters()

        panelId = @getPanelId summaryParameters
        panel = @panels.get panelId
        return if !panel

        switch @textType
          when @textTypes.full_text.name
            return if panel.get 'loaded'
            @onFullTextScroll panel, $panel
          when @textTypes.results.name
            return if panel.get('result')?.get('loaded')
            @onResultsScroll panel, $panel

    throttled = _.throttle fn, 500
    throttled()

  isOpen: =>
    $('.page').hasClass @openClass

  summarize: (parameters) ->
    $.post('/narratives/summarize', parameters)

  fetchText: (page, summaryParameters, limit = 5) ->
    options =
      limit: limit
      optimize: true
      filter_ids: summaryParameters.ids
      where: "USERTXT is not null AND
        report_type = '#{Visio.Utils.dbMetric(summaryParameters.reported_type)}' AND
        year = '#{summaryParameters.year}'"
      offset: limit * page

    $.post('/narratives', options)


  fetchSummary: (token, panel, timeout, attempts) ->
    timeout or= 2000
    nAttempts = 20
    $panel = @$el.find(".panel .panel-summary-#{@model.cid}")
    $panel.text 'thinking...!'

    doneFn = (resp) =>
      nAttempts += 1
      if resp.success and resp.complete
        panel.set 'summary', resp.summary
        $panel.text resp.summary
      else
        console.log 'trying again'
        if !attempts? or nAttempts < attempts
          window.setTimeout (() -> $.get("/narratives/status/#{token}").done doneFn), timeout

    $.get("/narratives/status/#{token}").done doneFn

  onFocus: (e) ->
    e.stopPropagation()
    @$el.find('.query-by').addClass 'open'

  onBlur: (e) ->
    e.stopPropagation()
    @$el.find('.query-by').removeClass 'open'

  onQuery: (e) ->
    e.stopPropagation()
    $target = $ e.currentTarget
    query = $target.val()

    @textType = @textTypes.results.name
    $("#np-#{@textType}-#{@model.cid}").prop('checked', true)

    throttledRender = _.throttle (() => @renderTextType @textType, { query: query }), 300
    throttledRender()

  close: ->
    $.unsubscribe 'narratify-toggle-state'
    $.unsubscribe 'narratify-close'
    $.unsubscribe 'narratify'
    @unbind()
    @remove()


