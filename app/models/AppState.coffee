Spine = require('spine')

class AppModel extends Spine.Model
  @configure 'AppModel'
  
  constructor: ->
    super
  
  validate: ->
    

AppModel.TILE_SIZE = 256

module.exports = AppModel
