$ = JQuery = require('jqueryify')

TILE_SERVER = 'http://localhost:8989'

class VectorField extends Spine.Module
  @extend(Spine.Events)

  constructor: (tileSize, sub_sample=1) ->
    console.log("VectorField")
    @tileSize = tileSize
    @sub_sample = sub_sample
    @maxZoom = 19
    @minZoom = 1
    @name = 'oceanSurfaceCurrents'
    @name = 'ocean surface currents'


  getTile: (coord, zoom, ownerDocument) ->
    console.log('getTile', coord.toString(), zoom.toString())
    VectorField.trigger('loading', coord, zoom)
    
    div = ownerDocument.createElement('div');
    div.innerHTML = coord;
    div.style.width = this.tileSize.width + 'px';
    div.style.height = this.tileSize.height + 'px';
    div.style.fontSize = '10';
    div.style.borderStyle = 'solid';
    div.style.borderWidth = '1px';
    div.style.borderColor = '#AAAAAA';

    tile_size_ = this.tileSize.height
    field_size = this.tileSize.height / this.sub_sample

    args = 
        x : coord.x
        y : coord.y
        zoom : zoom,
        size : tile_size_
        sub_sample : this.sub_sample

    field_size = this.tileSize.height / this.sub_sample

    $.getJSON(TILE_SERVER + '/tile/surrface_current.json', args, (data) ->

        u_arr = data.u
        v_arr = data.v

        VectorField.trigger('loaded', coord, zoom)
    )

    $.data(div, 'tile', {zoom:zoom, coord:coord})
    return div
    
  releaseTile: (tile) ->
    data = $.data(tile, 'tile')
    VectorField.trigger('unload', data.coord, data.zoom)

module.exports = VectorField;

