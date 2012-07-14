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

    buttons_ =
        Ok: -> $( this ).dialog( "close" ),
        Cancel: -> $( this ).dialog( "close" )

  resize: =>
    hh1 = @header.height()
    dh1 = @el.height()

    @container.height(dh1 - hh1 - 2)
    @side_bar.height(dh1 - hh1 - 2)


module.exports = AppStyler

