MercatorProjection = require('lib/global_mercator')

class Particle
  constructor: (loc) ->
      @loc = loc
      @old_loc = loc
      @vel = 0
      @life = 100 + Math.floor(Math.random() * 100)

class ParticleSystem

    constructor: (max_particles, tile_size, zoom, overlay_proj, vector_field, sw, ne) ->

        @max_particles = max_particles
        @zoom = zoom
        @tile_size = tile_size
        @merc = new MercatorProjection(zoom, tile_size)
        @overlay_proj = overlay_proj
        @vector_field = vector_field
        @particles = new Array(max_particles)

        @bottom_right = @merc.fromLatLngToPoint(sw)
        @top_left = @merc.fromLatLngToPoint(ne)

        for i in [0..max_particles-1]
            @particles[i] = @new_particle()

    new_particle: ->
        x = (Math.random() * (@bottom_right.x - @top_left.x)) + @top_left.x
        y = (Math.random() * (@bottom_right.y - @top_left.y)) + @top_left.y
        loc = new google.maps.Point(x, y)

        return new Particle(loc)

    step: ->

        ntiles = 1<<@zoom
        for i in [0..@max_particles-1]
            particle = @particles[i]

            unless particle.life > 0
                @particles[i] = @new_particle()

            new_velocity = @vector_field.get(@zoom, particle.loc)
            particle.old_loc = particle.loc
            #particle.loc = new google.maps.Point(particle.loc.x + new_velocity.x*2*ntiles, particle.loc.y + new_velocity.y*2*ntiles)
            particle.loc = new google.maps.Point(particle.loc.x + new_velocity.x/ ntiles * 20,
                                                 particle.loc.y + new_velocity.y/ ntiles * 20)
            particle.vel = new_velocity.md()
            particle.life-=1

    render: (canvas) ->
        context = canvas.getContext('2d')

        context.lineWidth = .5

        ntiles = 1 << @zoom
        for i in [0..@max_particles-1]
            particle = @particles[i]
            if particle.vel < .00001
                continue

            start_x = (particle.old_loc.x - @bottom_right.x) * ntiles
            start_y = (particle.old_loc.y - @top_left.y) * ntiles

            end_x = (particle.loc.x - @bottom_right.x) * ntiles
            end_y = (particle.loc.y - @top_left.y) * ntiles

            #x = particle.vel/(@vector_field.max_velocity*.9)
            #r = Math.round(x * 89 + 166)
            #r = Math.max(Math.min(r, 255), 0)
            #g = Math.round(x * 64 + 191)
            #g = Math.max(Math.min(r, 255), 0)
            #context.strokeStyle = 'rgb('+r+', '+g+', '+r+')'

            context.strokeStyle = 'rgb(255,255,255)'

            context.beginPath()
            context.moveTo(start_x, start_y)
            context.lineTo(end_x, end_y)
            context.stroke()

module.exports = ParticleSystem
