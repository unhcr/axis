class Visio.Views.AbsyView extends Visio.Views.Module

  @include Visio.Mixins.Narratify

  template: HAML['modules/absy']

  className: 'module'

  id: 'absy'

  initialize: (options) ->
    width = $('#module').width()

    unless $('.page').hasClass('shift')
      width -= (Visio.Constants.LEGEND_WIDTH + 40)

    config =
      width: width
      height: 600
      margin:
        top: 90
        bottom: 90
        left: 140
        right: 80

    @figure = new Visio.Figures.Absy config
    @queryBy = new Visio.Views.QueryBy figure: @figure

    @narratify @figure

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
