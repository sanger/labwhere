$.fn.fade = (time) -> this.fadeOut time

$(document).ajaxError (e, XHR, options) ->
  if(XHR.status == 401)
    $("#flash").show()
    $("#flash").append("<div class='alert'><p>"+ XHR.responseText + "</p></div>")
    $(".alert").fade(15000)

$.fn.addDialog = (partial, title) ->
  this.dialog
    autoOpen: true
    height: 400
    width: 600
    title: title
    open: -> $(this).html(partial)
    buttons:
      Cancel: -> $(this).dialog("close")

this.removeAllLabwares = removeAllLabwares = (id) -> 
  alert("remove all labwares for" + id)
  $("#remove-all-labwares-form").addDialog("<%= escape_javascript(render('remove_all_labwares')) %>", "Remove all Labware")