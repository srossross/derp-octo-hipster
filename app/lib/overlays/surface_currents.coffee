$ = JQuery = require('jqueryify')
AppState = require('models/AppState')
VectorField = require('lib/map_types/vector_field')
ParticleSystem = require('lib/particle_system')

OverlayViewCls = new google.maps.OverlayView()

class SurfaceCurrentsOverlayBase

SurfaceCurrentsOverlayBase.prototype = new google.maps.OverlayView()

window.requestAnimFrameDefault = (callback) ->
    window.setTimeout(callback, 1000 / 60)

window.requestAnimFrame = (callback) ->
  timeout = (window.requestAnimationFrame  || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame ||
             window.msRequestAnimationFrame || window.requestAnimFrameDefault)

  #window.setTimeout(callback, 100)
  return timeout(callback)


class SurfaceCurrentsOverlay extends SurfaceCurrentsOverlayBase
  constructor: (map) ->
    @map_ = map;

    @div_ = null;


    size = AppState.TILE_SIZE
    @vector_field = new VectorField(new google.maps.Size(size, size), 4);

    @pause = false
    @stop_animation_ = false
    @f_count=0

  onAdd: ->
    div = document.createElement('div');
    div.style.borderStyle = "none";
    div.style.borderWidth = "0px";
    div.style.position = "absolute";

    # Create an IMG element and attach it to the DIV.
    canvs = document.createElement("canvas");
    div.appendChild(canvs);

    @canvs_ = canvs;
    @div_ = div;

    # We add an overlay to a map via one of the map's panes.
    # We'll add this overlay to the overlayImage pane.
    panes = @getPanes()
    panes.overlayImage.appendChild(div)

    google.maps.event.addListener(this.map_, 'bounds_changed', @bounds_changed)

    @map_.overlayMapTypes.insertAt(0, @vector_field);

    this.bounds_changed();
    return

  onRemove: ->
    @div_.parentNode.removeChild(this.div_);
    @div_ = null;
    @stop_animation();

    overlays = @map_.overlayMapTypes;

    for i in [0..overlays.length]
      if overlays.getAt(i) is @vector_field
         overlays.removeAt(i)
         break

  draw: ->
    overlayProjection = @getProjection()

    bnds = @map_.getBounds()

    sw = overlayProjection.fromLatLngToDivPixel(bnds.getSouthWest())
    ne = overlayProjection.fromLatLngToDivPixel(bnds.getNorthEast())

    # Resize the image's DIV to fit the indicated dimensions.
    width = $(@map_.getDiv()).width()
    height = $(@map_.getDiv()).height()

    @div_.style.left = sw.x + 'px';
    @div_.style.top = ne.y + 'px';

    @div_.style.width = width + 'px';
    @div_.style.height = height + 'px';

    @canvs_.width = width;
    @canvs_.height = height;

    context = this.canvs_.getContext('2d');

    if !context
        alert("This browser does not support html5 canvas")

    context.clearRect(0, 0, this.canvs_.width, this.canvs_.height)

  bounds_changed: =>
    bnds = @map_.getBounds()

    if bnds is undefined
        return

    sw = bnds.getSouthWest()
    ne = bnds.getNorthEast()

    args =
        south : sw.lat()
        west : sw.lng()
        north : ne.lat()
        east : ne.lng()
        zoom : @map_.getZoom()

    overlayProjection = @getProjection()

    if !overlayProjection
        return

    sw = bnds.getSouthWest()
    ne = bnds.getNorthEast()

    swp = overlayProjection.fromLatLngToDivPixel(sw)
    nep = overlayProjection.fromLatLngToDivPixel(ne)

    context = @canvs_.getContext('2d');
    context.clearRect(0, 0, @canvs_.width, @canvs_.height);

    state = AppState.first()
    @particle_system = new ParticleSystem(state.max_particles, AppState.TILE_SIZE, @map_.getZoom(), overlayProjection, @vector_field, sw, ne)

  start_animation: ->
    @stop_animation_ = false
    window.requestAnimFrame(@animate)

  stop_animation: ->
    @stop_animation_ = true

  animate: =>
    if @stop_animation_
      return

    if !@pause && @particle_system
      @particle_system.step()
      @fade3()
      @particle_system.render(@canvs_)

    window.requestAnimFrame(@animate)

  fade: (context) ->
    imageData = context.getImageData(0, 0, @canvs_.width, @canvs_.height)
    data = imageData.data

    for i in [0..data.length]
      if data[i + 3] > 3
        data[i + 3] -= 3
      else
        data[i + 3] = 0

    context.putImageData(imageData, 0, 0)

  fade3: ->
      @f_count += 1

      if @f_count == 4
          @f_count = 0
          context = @canvs_.getContext('2d')
          #context.globalAlpha = .99
          context.globalCompositeOperation = 'source-atop'

          context.fillStyle = 'rgba(166, 191, 221, .1)'
          context.fillRect(0, 0, @canvs_.width, @canvs_.height)

          #context.globalAlpha = 1
          context.globalCompositeOperation = 'source-over'

  fade2: ->
    dataURL = @canvs_.toDataURL()
    img = new Image()
    img.onload = =>
        context = @canvs_.getContext('2d')
        context.globalAlpha = .9
        context.drawImage(img,0,0)
        context.globalAlpha = 1
    img.src = dataURL

module.exports = SurfaceCurrentsOverlay

