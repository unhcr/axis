class Visio.Views.BmyView extends Visio.Views.AccordionIndexView

  showView: (options) -> new Visio.Views.BmyShowView(options)

  id: 'bmy'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  sort: (parameterA, parameterB) ->
    0
