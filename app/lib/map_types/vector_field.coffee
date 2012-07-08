$ = JQuery = require('jqueryify')
AppState = require('models/AppState')

class VectorField extends Spine.Module
    @extend(Spine.Events)

    constructor: (tileSize, sub_sample=1) ->
        super

        @tileSize = tileSize
        @sub_sample = sub_sample
        @maxZoom = 19
        @minZoom = 1
        @name = 'oceanSurfaceCurrents'
        @name = 'ocean surface currents'
        @tiles_ = {}
        @max_velocity = -1


        @is_ready = false

        url = AppState.TILE_SERVER + '/tile/ready.json'

        $.ajax({
            url: url,
            dataType: 'json',
            data: {},
            success:  =>
                VectorField.trigger('ready')
                @is_ready = true
            error: =>
                @is_ready = false
                VectorField.trigger('error')
        })


    getTile: (coord, zoom, ownerDocument) ->

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

        url = AppState.TILE_SERVER + '/tile/surrface_current.json'

        if @is_ready

            $.getJSON(url, args, (data) =>
                unless @tiles_[zoom]
                    @tiles_[zoom] = {}
                @tiles_[zoom][[coord.x,coord.y]] = data

                len = (tile_size_ / @sub_sample) - 1
                for i in [0..len]
                    for j in [0..len]
                        try
                            u = data.u[i][j]
                            v = data.v[i][j]
                        catch error
                            uadfdff

                        vel = Math.sqrt(u * u + v * v)
                        if vel > @max_velocity
                            @max_velocity = vel
                VectorField.trigger('loaded', coord, zoom)
            )

        $.data(div, 'tile', {zoom:zoom, coord:coord})
        return div

    releaseTile: (tile) ->
        data = $.data(tile, 'tile')
        VectorField.trigger('unload', data.coord, data.zoom)

        unless @tiles_[data.zoom]
            return

        @tiles_[data.zoom][[data.coord.x, data.coord.y]] = null

    get: (zoom, world_coords) ->
        tile_size_ = this.tileSize.height

        unless @tiles_[zoom]
            return new google.maps.Point(0,0)
        ntiles = 1 << zoom

        pixel_x = world_coords.x
        pixel_y = world_coords.y

        tile_x =  Math.floor(pixel_x / tile_size_)
        tile_y =  Math.floor(pixel_y / tile_size_)

        unless @tiles_[zoom][[tile_x, tile_y]]
            return new google.maps.Point(0,0)

        data = @tiles_[zoom][[tile_x, tile_y]]

        pixel_x = (pixel_x - (tile_x*tile_size_)) / @sub_sample
        pixel_y = (pixel_y - (tile_y*tile_size_)) / @sub_sample

        idx_x = Math.floor(pixel_x)
        idx_y = Math.floor(pixel_y)

        rat_x = pixel_x - idx_x
        rat_y = pixel_y - idx_y

        field_size_ = (tile_size_ / @sub_sample) - 1

        if idx_x < 0
            idx_x0 = 0
            idx_x1 = 0
        else if idx_x >= (field_size_)
            idx_x0 = field_size_
            idx_x1 = field_size_
        else
            idx_x0 = idx_x
            idx_x1 = idx_x + 1

        if idx_y < 0
            idx_y0 = 0
            idx_y1 = 0
        else if idx_y >= (field_size_)
            idx_y0 = field_size_
            idx_y1 = field_size_
        else
            idx_y0 = idx_y
            idx_y1 = idx_y + 1


        y0 = data.u[idx_y0][idx_x0] * (1-rat_x) + data.u[idx_y0][idx_x1] * (rat_x)
        y1 = data.u[idx_y1][idx_x0] * (1-rat_x) + data.u[idx_y1][idx_x1] * (rat_x)

        u = y0 * (1-rat_y) + y1 * (rat_y)

        y0 = data.v[idx_y0][idx_x0] * (1-rat_x) + data.v[idx_y0][idx_x1] * (rat_x)
        y1 = data.v[idx_y1][idx_x0] * (1-rat_x) + data.v[idx_y1][idx_x1] * (rat_x)

        v = y0 * (1-rat_y) + y1 * (rat_y)

        return new google.maps.Point(u, v)

module.exports = VectorField;

