Spine = require('spine')
require('spine/lib/local')

class AppState extends Spine.Model

  @configure 'AppState', 'show_ctrls', 'show_currents', 'maptypeid', 'zoom', 'center_lat', 'center_lng', 'max_particles', 'debug'
  @extend Spine.Model.Local

  constructor: ->
      super
      @max_particles = 7000

  validate: ->
    return

AppState.bind('error', (mdl, msg) -> alert(msg))

AppState.TILE_SIZE = 256
#AppState.TILE_SERVER = 'http://localhost:5000'
AppState.TILE_SERVER = 'http://ec2-184-73-123-94.compute-1.amazonaws.com/'
module.exports = AppState

