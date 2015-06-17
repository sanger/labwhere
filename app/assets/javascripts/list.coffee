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
    @clicker.on "click", @findData

  findData: (event) =>
    event.preventDefault()
    for resource in @behavior.childResources
      list = @item.find("[data-behavior~=#{window.behaviors.find(resource.behavior).id}]")
      if list.length
        @toggleList list
      else
        @fireAjax(resource)

  fireAjax: (resource) =>
    $.ajax
      url: "/#{@behavior.parentResource}/#{@id}/#{resource.path}"
      async: false
      method: "GET"
      dataType: "HTML"
      success: (data, textStatus, jqXHR) =>
        @handleSuccess(data, resource)
    
  handleSuccess: (results, resource) =>
    html = $(results).find("#collection")
    @addBehavior(html, resource.behavior)
    html.appendTo(@item)
    @clicker.html '-'

  addBehavior: (html, resource) =>
    behavior = window.behaviors.find(resource)
    html.data("behavior", behavior.id)
    new List(html, behavior)

  toggleList: (list) =>
    if list.is(":visible")
      list.hide()
      @clicker.html '+'
    else
      if list.find("article").length
        list.show()
        @clicker.html '-'
