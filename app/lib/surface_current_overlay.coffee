$ = JQuery = require('jqueryify')
AppState = require('models/AppState')
VectorField = require('lib/vector_field_maptype')

OverlayViewCls = new google.maps.OverlayView()

class SurfaceCurrentsOverlayBase
    
SurfaceCurrentsOverlayBase.prototype = new google.maps.OverlayView()

class SurfaceCurrentsOverlay extends SurfaceCurrentsOverlayBase
  constructor: (map) ->
    @map_ = map;

    @div_ = null;

    this.bounds_changed();
    
    size = AppState.TILE_SIZE
    @vector_field = new VectorField(new google.maps.Size(size, size), 4);
    console.log('constr', @vector_field, size)

  onAdd: ->
    console.log('onAdd')
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
    
    console.log('onAdd', @vector_field)
    console.log('onAdd', @map_.overlayMapTypes)
    @map_.overlayMapTypes.insertAt(0, @vector_field);
    
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

    swp = overlayProjection.fromLatLngToDivPixel(bnds.getSouthWest())
    nep = overlayProjection.fromLatLngToDivPixel(bnds.getNorthEast())

    width = $(@map_.getDiv()).width()
    height = $(@map_.getDiv()).height()

    context = @canvs_.getContext('2d');
    context.clearRect(0, 0, @canvs_.width, @canvs_.height);
    
    
  start_animation: ->
    
  stop_animation: ->
    

module.exports = SurfaceCurrentsOverlay

    