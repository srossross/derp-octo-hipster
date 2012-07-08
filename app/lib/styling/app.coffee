$ = JQuery = require('jqueryify')
Spine = require('spine')

class AppStyler extends Spine.Controller

  elements:
    '#header': 'header'
    'body': 'body'
    '.container': 'container'
    '.sidebar': 'side_bar'
    '.fbutton' : 'buttons'

  constructor: ->
    super

    @resize()
    $(window).resize(@resize);

    console.log(@buttons)
    @buttons.button()

    $("#datepicker").datepicker(
      changeMonth: true
      changeYear: true
    )

    $('.fbutton').button()

    $('#go_search').button(
        icons: { primary: "ui-icon-search"}
        text: false
        )

    $( "#error-dialog-message" ).dialog({
      modal: true
      autoOpen: false
      resizable: false
      draggable: false
      title: "Loading Surface Currents"
      width: 600
      dialogClass: "alert"
      })


    buttons_ =
        Ok: -> $( this ).dialog( "close" ),
        Cancel: -> $( this ).dialog( "close" )

    $("#settings-dialog-message").dialog({ modal: true, autoOpen: false, resizable: false, draggable: false, title: "Application Settings", buttons_ : buttons_    })


    $('.load_info').button({text: false})
    $('#settings').button({text: true, icons: { primary: "ui-icon-gear-custom"}})

  resize: =>
    hh1 = @header.height()
    dh1 = @el.height()

    @container.height(dh1 - hh1 - 2)
    @side_bar.height(dh1 - hh1 - 2)


module.exports = AppStyler

