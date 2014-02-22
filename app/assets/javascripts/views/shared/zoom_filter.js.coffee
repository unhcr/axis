class Visio.Views.ZoomFilterView extends Backbone.View

  className: 'zoom-filter map-filter'

  template: HAML['shared/zoom_filter']

  initialize: () ->
    @render()

  events:
    'click .zoom-in': 'onZoomIn'
    'click .zoom-out': 'onZoomOut'

  render: () ->
    @$el.html @template()
    @

  onZoomIn: () ->
    Visio.router.map.zoomIn()

  onZoomOut: () ->
    Visio.router.map.zoomOut()

