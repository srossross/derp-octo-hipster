Spine = require('spine')

class AppState extends Spine.Model
  @configure 'AppState'
  
  constructor: ->
    super
  
  validate: ->
    

AppState.TILE_SIZE = 256
AppState.TILE_SERVER = 'http://localhost:8989'

module.exports = AppState
