# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @List

  constructor: (item, behavior) ->
    @item       = $(item)
    @list       = $.map @item.find("[data-behavior~=#{behavior.name}]"), (item, i) ->
      new ListItem(item, behavior)

class @ListItem
  
  constructor: (item, behavior) ->
    @item             = $(item)
    @behavior         = behavior
    @id               = @item.data("id")
    @clicker          = @item.find("[data-behavior~=drilldown]").first()
    @setEvents()

  setEvents: ->
    @clicker.on "click", @addData

  addData: (event) =>
    event.preventDefault()
    list = @item.find("[data-behavior~=#{@behavior.id}]")
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
      @fireAjax("/locations/#{@id}/children")
      @fireAjax("/locations/#{@id}/labwares")
    ).then (results1, results2) =>
      @handleSuccess results1[0], results2[0]

  fireAjax: (url) =>
    $.ajax
      url: url
      method: "GET"
      dataType: "HTML"
    
  handleSuccess: (results1, results2) =>
    html = $(results1).find("#collection")
    html.data("behavior", "locations-list")
    new List(html, @behavior)
    html.appendTo(@item)
    @clicker.html '-'
    html = $(results2).find("#collection")
    html.data("behavior", "labwares-list")
    new LabwaresList(html)
    html.appendTo(@item)
    @clicker.html '-'

jQuery ->
  console.log(this.behaviors)
  new List($("[data-behavior~=locations-list]"), new Behavior(name: "location", resources: [ { path: "children", behavior: "location" }, { path: "labwares", behavior: "labware" } ]))