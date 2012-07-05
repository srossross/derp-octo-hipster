require('lib/setup')

$ = JQuery = require('jqueryify')

Spine = require('spine')
AppState = require('models/AppState')
Overlay = require('lib/overlays/surface_currents')
VectorField = require('lib/map_types/vector_field')
SimpleMap = require('lib/map_types/styled_map')

class FlowApp extends Spine.Controller
  events:
    "change  .toggle_controls": "toggle_controls"
    "change  .toggle_overlay": "show_overlay_changed"
    "click  #settings": "open_settings"

  elements:
    "#map_canvas":     "map_canvas"
    "div.search input[type='text']":     "map_search"
    "input[type='checkbox'].toggle_controls":     "control_checkbox"
    "input[type='checkbox'].toggle_overlay":     "overlay_checkbox"
    "#sc_progress":     "sc_progress"
    "#prg":     "progress_div"
    "#settings" : "settings"

  constructor: ->
    super

    state = AppState.first()

    if (state == null || state == undefined)
      state = new AppState()
      state.save()

    if state.center
      center = new google.maps.LatLng(state.center.lat, state.center.lng);
    else
      center = new google.maps.LatLng(24.5, -89.5);

    show_ctrls = @control_checkbox[0].checked

    myOptions =
          zoom: if state.zoom then state.zoom else 6
          # center:  if state.center then state.center else myLatLng
          center:  center
          mapTypeId: google.maps.MapTypeId.TERRAIN

          streetViewControl:false
          mapTypeControl:show_ctrls
          zoomControl:show_ctrls
          scaleControl:show_ctrls
          panControl:show_ctrls
          overviewMapControl:show_ctrls

          mapTypeControlOptions:
            mapTypeIds: [google.maps.MapTypeId.TERRAIN, google.maps.MapTypeId.SATELLITE, SimpleMap.ID]
            style: google.maps.MapTypeControlStyle.DROPDOWN_MENU


    @map = new google.maps.Map(@map_canvas[0], myOptions)

    @map.mapTypes.set(SimpleMap.ID, SimpleMap);
    @map.setMapTypeId(SimpleMap.ID);

    @autocomplete = new google.maps.places.Autocomplete(@map_search[0])
    @autocomplete.bindTo('bounds', @map)
    google.maps.event.addListener @autocomplete, 'place_changed', (event) => @place_changed()

    @surface_overlay = new Overlay(@map)
    @show_overlay_changed()

    @setup_progress_bar()

  setup_progress_bar: ->

    VectorField.bind('loading', =>
      $('#prg:hidden').show('blind')

      max = parseInt(@sc_progress.attr('max'))
      @sc_progress.attr('max', max + 1)
      )
    VectorField.bind('loaded', =>
      max = parseInt(@sc_progress.attr('max'))
      value = parseInt(@sc_progress.attr('value'))
      @sc_progress.attr('value', value + 1)
      if max == value + 1
        $('#prg:visible').hide('blind')
        @sc_progress.attr('value', null)
        @sc_progress.attr('max', 0)
      )

    VectorField.bind('error', =>
        $('#prg').addClass('ui-state-error')
      )

    $('#prg:visible').hide()

  save_state: =>
    state = AppState.first()
    if (state == null || state == undefined)
      return

    state.save()

  show_overlay_changed: (event)->
    show = @overlay_checkbox[0].checked
    if show
      @surface_overlay.setMap(@map)
      @surface_overlay.start_animation()
      $('#prg:hidden').show('blind')
    else
      @surface_overlay.setMap(null)
      $('#prg:visible').hide('blind')

  toggle_controls: (event) ->

    show_ctrls = @control_checkbox[0].checked

    myOptions =
          mapTypeControl:show_ctrls
          zoomControl:show_ctrls
          scaleControl:show_ctrls
          panControl:show_ctrls
          overviewMapControl:show_ctrls

    @map.setOptions(myOptions)


  place_changed: ->
    @map_search.removeClass('ui-state-error')

    place = @autocomplete.getPlace()

    unless place
      @map_search.addClass('ui-state-error')

    if place.geometry.viewport
      @map.fitBounds(place.geometry.viewport)
    else
      @map.setCenter(place.geometry.location)

  open_settings: ->
    console.log('open_settings')

module.exports = FlowApp

