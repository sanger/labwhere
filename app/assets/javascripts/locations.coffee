# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('.select2_box').select2()
  $(".select2_box").next(".select2").find(".select2-selection").focus(() ->
    $(".select2_box").select2("open")
  )