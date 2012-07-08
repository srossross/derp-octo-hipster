

window.bound = (value, opt_min, opt_max) ->
    if opt_min != null
        value = Math.max(value, opt_min)
    if opt_max != null
        value = Math.min(value, opt_max)

    return value

window.degreesToRadians = (deg) ->
  return deg * (Math.PI / 180)

window.radiansToDegrees = (rad) ->
  return rad / (Math.PI / 180)


class MercatorProjection
  constructor: (zoom, tileSize) ->
    @zoom_ = zoom
    @ntiles_ = 1 << zoom
    @tileSize_ = tileSize;
    @pixelOrigin_ = new google.maps.Point(tileSize / 2, tileSize / 2);
    @pixelsPerLonDegree_ = tileSize / 360;
    @pixelsPerLonRadian_ = tileSize / (2 * Math.PI);

  fromLatLngToPixel: (latLng, opt_point) ->
      point = @fromLatLngToPoint(latLng, opt_point)
      point.x *= @ntiles_
      point.y *= @ntiles_
      return point

  fromLatLngToPoint: (latLng, opt_point) ->
    origin = @pixelOrigin_

    point = opt_point || new google.maps.Point(0, 0)

    point.x = origin.x + latLng.lng() * @pixelsPerLonDegree_

    # NOTE(appleton): Truncating to 0.9999 effectively limits latitude to
    # 89.189.  This is about a third of a tile past the edge of the world
    # tile.
    siny = window.bound(Math.sin(window.degreesToRadians(latLng.lat())), -0.9999, 0.9999)
    point.y = origin.y + 0.5 * Math.log((1 + siny) / (1 - siny)) * -@pixelsPerLonRadian_
    return point

  fromPointToLatLng: (point) ->
    origin = @pixelOrigin_
    lng = (point.x - origin.x) / @pixelsPerLonDegree_

    latRadians = (point.y - origin.y) / -@pixelsPerLonRadian_
    lat = window.radiansToDegrees(2 * Math.atan(Math.exp(latRadians)) - Math.PI / 2)
    return new google.maps.LatLng(lat, lng)

module.exports = MercatorProjection
