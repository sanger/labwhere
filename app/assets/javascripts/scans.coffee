# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on("turbolinks:load", ->
  $(".notice").fade 10000
  $(".alert").fade 15000
  $('nav li ul').hide()
  $('nav li').hover(
    -> $('ul', this).stop().slideDown(100),
    -> $('ul', this).stop().slideUp(100)
    )
  scannedTextArea = document.getElementById('scan_labware_barcodes')
  if scannedTextArea
    CodeMirror.fromTextArea(scannedTextArea, {
      lineNumbers: true,
      mode: "barcode_reader"
    })

  moveLocationTextArea = document.getElementById('move_location_form_child_location_barcodes')
  if moveLocationTextArea
    CodeMirror.fromTextArea(moveLocationTextArea, {
      lineNumbers: true,
      mode: "barcode_reader"
    })
)