# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('.select2_box').select2()
  $(".select2_box").next(".select2").find(".select2-selection").focus(() ->
    $(".select2_box").select2("open")
  )

  containerChange = () ->
    if($('#location_container').is(':checked'))
      $('.container-options').show()
    else
      $('.container-options').hide()

  coordinateChange = () ->
    if($('#location_coordinated').is(':checked'))
      $('.coordinate-options').show()
    else
      $('.coordinate-options').hide()
      $('#location_rows').val(0)
      $('#location_columns').val(0)

  $('#location_container').change(containerChange)
  $('#location_coordinated').change(coordinateChange)
  containerChange()
  coordinateChange()