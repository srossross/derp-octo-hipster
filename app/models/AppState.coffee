Spine = require('spine')
require('spine/lib/local')

class AppState extends Spine.Model

  @configure 'AppState', 'show_ctrls', 'show_currents', 'maptypeid', 'zoom', 'center_lat', 'center_lng', 'max_particles'
  @extend Spine.Model.Local

  constructor: ->
      super
      @max_particles = 2000

  validate: ->
    return

AppState.bind('error', (mdl, msg) -> alert(msg))

AppState.TILE_SIZE = 256
AppState.TILE_SERVER = 'http://localhost:8989'

module.exports = AppState

