# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @Select2
  constructor: (item) ->
    @item = $(item)
    @addSelect2()
    @addListener()

  addSelect2: ->
    @item.select2({width: '102%'})

  addListener: ->
    @item.next(".select2").find(".select2-selection").focus =>
      @item.select2("open")

class @Location

  constructor: (item) ->
    @item             = $(item)
    @addListeners()
    @toggleAll()

  addListeners: =>
    self = @
    @item.on "change", "[data-toggle~=container],[data-toggle~=coordinates]", (event) ->
      self.toggleSelector($(this))

  toggleSelector: (item) =>
    toggled = @item.find("[data-behavior~=" + item.data("toggle") + "]")
    if item.is(':checked')
      toggled.show()
    else
      toggled.hide()
      toggled.find('input[type="text"]').val(0)

  toggleAll: =>
    $.each [ "container", "coordinates" ], (index, value) =>
      @toggleSelector(@item.find("[data-toggle~=" + value + "]"))


$(document).on("turbolinks:load", ->
  for item in $("[data-behavior~=location]")
    new Location item

  for item in $("[data-behavior~=select2]")
    new Select2 item
)
