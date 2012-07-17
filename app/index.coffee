###

## My Titile
This is the main doc for the flow app

###
require('lib/setup')

$ = JQuery = require('jqueryify')

Spine = require('spine')
AppState = require('models/AppState')
Overlay = require('lib/overlays/surface_currents')
VectorField = require('lib/map_types/vector_field')
SimpleMap = require('lib/map_types/styled_map')

ServerInfo = require('controllers/ServerInfo')
Settings = require('controllers/Settings')

class FlowApp extends Spine.Controller

    events:
        "change  .toggle_controls": "toggle_controls"
        "change  .toggle_overlay": "show_overlay_changed"
        "click  #open_settings": "open_settings"
        "click  #go_search": "place_changed"

    elements:
        "#map_canvas":     "map_canvas"
        "input.search_field":     "map_search"
        "input[type='checkbox'].toggle_controls":     "control_checkbox"
        "input[type='checkbox'].toggle_overlay":     "overlay_checkbox"
        "#sc_progress":     "sc_progress"
        "#settings" : "settings"

    constructor: ->
        super

        AppState.bind 'refresh', @state_loaded

        center = new google.maps.LatLng(24.5, -89.5);

        show_ctrls = @control_checkbox[0].checked

        myOptions =
              zoom: 6
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
        google.maps.event.addListener(@map, 'center_changed', =>
            if @state?
              @state.updateAttributes(center_lat : @map.getCenter().lat())
              @state.updateAttributes(center_lng : @map.getCenter().lng())
            )
        google.maps.event.addListener(@map, 'zoom_changed', => @state.updateAttributes(zoom: @map.getZoom()) if @state?)
        google.maps.event.addListener(@map, 'maptypeid_changed', => @state.updateAttributes(maptypeid: @map.getMapTypeId()) if @state?)

        @map.mapTypes.set(SimpleMap.ID, SimpleMap);
        @map.setMapTypeId(SimpleMap.ID);

        @autocomplete = new google.maps.places.Autocomplete(@map_search[0])
        @autocomplete.bindTo('bounds', @map)
        google.maps.event.addListener @autocomplete, 'place_changed', (event) => @place_changed()

        @surface_overlay = new Overlay(@map)

        @setup_progress_bar()

        @el.unload @save_state
        AppState.fetch()

        @server_info = new ServerInfo(el:"#prg")
        @settings = new Settings(el:"#settings-dialog")
        @log(@settings)

    state_loaded: =>
        @state = AppState.first()

        unless @state
            @state = new AppState()
            @state.maptypeid = google.maps.MapTypeId.TERRAIN
            @state.show_ctrls = true
            @state.show_currents = true
            @state.save()

        @control_checkbox[0].checked = @state.show_ctrls
        @toggle_controls()

        @map.setMapTypeId(@state.maptypeid) if @state.maptypeid?
        @map.setZoom(@state.zoom) if @state.zoom?
        @map.setZoom(@state.zoom) if @state.zoom?

        if @state.center_lat? and @state.center_lng?
            center = new google.maps.LatLng(@state.center_lat, @state.center_lng);
            @map.setCenter(center)

        @overlay_checkbox[0].checked = @state.show_currents
        @show_overlay_changed()

    save_state: =>
        state = AppState.first()
        unless state
            return
        state.show_ctrls = @control_checkbox[0].checked
        state.save()

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


    show_overlay_changed: (event) ->

        show = @overlay_checkbox[0].checked
        @state.updateAttributes(show_currents: show)
        if show
            @surface_overlay.setMap(@map)
            @surface_overlay.start_animation()
            $('#prg:hidden').show('blind')
        else
            @surface_overlay.setMap(null)
            @surface_overlay.stop_animation()
            $('#prg:visible').hide('blind')

    toggle_controls: (event) ->

        show_ctrls = @control_checkbox[0].checked

        @state.updateAttributes(show_ctrls: show_ctrls)
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

    open_settings: =>
        @settings.open()



module.exports = FlowApp
module.exports.AppState = AppState

