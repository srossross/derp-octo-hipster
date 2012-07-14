
$ = JQuery = require('jqueryify')
VectorField = require('lib/map_types/vector_field')


class ServerInfo extends Spine.Controller

    events:
        "click  #show_info": "render"

    elements:
        ".info_dialog" : "info_dialog"
        "#show_info" : "show_info"

    constructor: ->
        super

        console.log(@el)
        console.log(@show_info)
        $(@info_dialog).dialog({
            modal: true
            autoOpen: false
            resizable: false
            draggable: false
            title: "Loading Surface Currents"
            width: 600
            dialogClass: "alert"
        })

        @show_info.button({text: false})

        VectorField.bind('error', (response) =>
            @el.addClass('ui-state-error')
            @el.attr('title', 'Error: could not contact server')
            @el.attr('title', 'Error: could not contact server')
            $(@info_dialog).dialog({title: "Error Loading Surface Currents"})
            if response.status == 0
                @message = "Fatal error trying to connect to data server. Could not contact server."
            else
                @message = response.statusText
            @state = 'error'
            )

        $('#prg:visible').hide()

    render: ->
        html = require('views/server_info')(this)
        @info_dialog.html(html)
        $(@info_dialog).dialog('open')

module.exports = ServerInfo
