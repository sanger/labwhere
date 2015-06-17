# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @LabwaresList

  constructor: (item) ->
    @item       = $(item)
    @list       = $.map @item.find("[data-behavior~=labware]"), (item, i) ->
      new Labware(item)

class @Labware
  
  constructor: (item) ->
    @item             = $(item)
    @id               = @item.data("id")
    @clicker          = @item.find("[data-behavior~=drilldown]").first()
    @setEvents()

  setEvents: ->
    @clicker.on "click", @addData

  addData: (event) =>
    event.preventDefault()
    list = @item.find("[data-behavior~=labwares-list]")
    if list.length
      if list.is(":visible")
        list.hide()
        @clicker.html '+'
      else
        list.show()
        @clicker.html '-'
    else
      @findData()

  findData: =>
    $.when(
      $.ajax
        url: "/labwares/#{@id}/histories"
        method: "GET"
        dataType: "HTML"
    ).then (results) =>
      @handleSuccess results
    
  handleSuccess: (results...) =>
    for result in results
      html = $(result).find("#collection")
      html.data("behavior", "labwares-list")
      new LabwaresList(html)
      html.appendTo(@item)
      @clicker.html '-'

jQuery ->
  new LabwaresList $("[data-behavior~=labwares-list]")