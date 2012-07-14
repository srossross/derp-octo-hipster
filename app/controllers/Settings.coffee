Spine = require('spine')

class Settings extends Spine.Controller
    constructor: ->
        super

        buttons_ =
            Ok: -> $( this ).dialog( "close" ),
            Cancel: -> $( this ).dialog( "close" )

        @el.dialog({ modal: true, autoOpen: false, resizable: false, draggable: false, title: "Application Settings", buttons_ : buttons_    })

    open: =>
        @el.dialog('open')


module.exports = Settings