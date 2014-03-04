class Visio.Views.ActionSliderView extends Visio.Views.SliderView

  name:
    singular: 'action'
    className: 'Action'

  events:
    'change input': 'onSlideChange'

  onSlideChange: (e) ->
    slideNumber = $(e.currentTarget).val()
    @move(-slideNumber - @position)

