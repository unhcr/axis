class Visio.Views.AbsyView extends Backbone.View

  template: HAML['modules/absy']

  className: 'module'

  id: 'absy'

  initialize: (options) ->
    @config =
      width: 800
      height: 420
      margin:
        top: 40
        bottom: 90
        left: 90
        right: 80

    @figure = new Visio.Figures.Absy @config
    @queryBy = new Visio.Views.QueryBy figure: @figure

  render: (isRerender) ->

    if !isRerender
      @$el.html @template()
      @$el.find('#bubble').html @figure.el
      @$el.find('.header-buttons').append (new Visio.Views.FilterBy({ figure: @figure })).render().el
      @$el.find('.header-buttons').append @queryBy.render().el

    human = Visio.Utils.parameterByPlural(Visio.manager.get('aggregation_type')).human
    @queryBy.$el.find('input').attr 'placeholder', "Search for a #{human}"

    @figure.collectionFn(Visio.manager.selected(Visio.manager.get('aggregation_type')))
    @figure.render()

    @
