$ = JQuery = require('jqueryify')

class AppStyler extends Spine.Controller
  
  elements:
    '#header': 'header'
    'body': 'body'
    '#container': 'container'
    '#sidebarContainer': 'side_bar'
    '.btn' : 'buttons'

  constructor: ->
    super
    
    @resize()  
    $(window).resize(@resize);
    
    @buttons.button()
    
    $("#datepicker").datepicker(
      changeMonth: true
      changeYear: true
    )
    
  resize: =>
    hh1 = @header.height()
    dh1 = @el.height()
  
    @container.height(dh1 - hh1 - 2)
    @side_bar.height(dh1 - hh1 - 2)
    
    
root = exports ? this

$ -> 
    root.styler = new AppStyler(el:'body');

root.AppStyler = AppStyler
