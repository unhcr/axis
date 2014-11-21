class Visio.Views.ProtonView extends Backbone.View

  template: HAML['shared/proton']

  # Selectors
  dataVisLabelSe: '.data-vis-label'

  intervalTime: 7500
  explodeTime: 800
  nParticles: 3000

  initialize: (options) ->
    @rootIndex = 0
    @mouseObj

    @stats = options.stats

    @zones = []
    @images = []
    @loadCount = 0
    @contain = true
    @width = $(window).width()
    @height = $(window).height()


  createProton: ->
    @proton = new Proton()
    @emitter = new Proton.Emitter()
    @intervalId = null

    # setRate
    @emitter.rate = new Proton.Rate(new Proton.Span(@nParticles), new Proton.Span(0.1))

    @emitter.addInitialize(new Proton.Position(new Proton.PointZone(0, 0)))
    @emitter.addInitialize(new Proton.Radius(1))
    @emitter.addInitialize(new Proton.P(@zones[@rootIndex]))

    @mouseObj =
      x : 1003 / 2,
      y : 610 / 2

    @attractionBehaviour = new Proton.Attraction @mouseObj, 0, 0

    @randomBehaviour = new Proton.RandomDrift 0, 0, .05
    @gravity = new Proton.GravityWell({
      x : @canvas[0].width / 2,
      y : @canvas[0].height / 2
    }, 0, 0)

    @emitter.addBehaviour(@customToZoneBehaviour(@zones))
    @emitter.addBehaviour(new Proton.Color(['#3a3a3a', '#000000']))
    @emitter.addBehaviour(@attractionBehaviour)

    @randomBehaviour.reset(30, 30, 0.001)
    @emitter.addBehaviour(@randomBehaviour)

    @emitter.emit('once')
    @proton.addEmitter(@emitter)

    # canvas renderer
    @renderer = new Proton.Renderer('pixel', @proton, @canvas[0])
    @renderer.start()

  next: =>
    @contain = false

    fn = () =>
      @contain = true
      @rootIndex += 1
      @setLabel()
      @$el.find(@dataVisLabelSe).fadeIn(@explodeTime + 20)

    window.setTimeout fn, @explodeTime
    @$el.find(@dataVisLabelSe).fadeOut(@explodeTime + 20)

  setLabel: =>
    stat = @stats[@rootIndex % @stats.length]
    @$el.find(@dataVisLabelSe).text stat.name

  render: ->
    @$el.html @template
      width: @width
      height: @height
    @setLabel()

    @canvas = @$el.find 'canvas'

    @context = @canvas[0].getContext('2d')
    @context.globalCompositeOperation = "lighter"

    @rect = new Proton.Rectangle 0, 0, @canvas[0].width, @canvas[0].height

    @context.font = "150px helvetica"
    @context.fillStyle = "rgb(229, 86, 28)"

    _.each @stats, (stat) =>
      @context.fillText stat.value, 60, 225
      imagedata = @context.getImageData(@rect.x, @rect.y, @rect.width, @rect.height)
      @zones.push(new Proton.ImageZone(imagedata, @rect.x, @rect.y + 50))
      @context.clearRect 0, 0, @canvas[0].width, @canvas[0].height

    @createProton()
    @tick()

    window.clearInterval @intervalId
    window.setInterval @next, @intervalTime
    @


  customToZoneBehaviour: (zones) =>
    return {
      initialize : (particle) =>
        particle.R = Math.random() * 10
        particle.Angle = Math.random() * Math.PI * 2
        particle.speed = Math.random() * (-2) + 1
        particle.zones = _.map zones, (z) -> z.getPosition().clone()

      applyBehaviour : (particle) =>
        if @contain
          particle.v.clear()
          particle.Angle += particle.speed
          x = particle.zones[@rootIndex % particle.zones.length].x + particle.R * Math.cos(particle.Angle)
          y = particle.zones[@rootIndex % particle.zones.length].y + particle.R * Math.sin(particle.Angle)
          particle.p.x += (x - particle.p.x) * 0.05
          particle.p.y += (y - particle.p.y) * 0.05
    }

  tick: =>
    window.requestAnimationFrame @tick.bind(@)
    @proton.update()

