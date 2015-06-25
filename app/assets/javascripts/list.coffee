class @List

  constructor: (item, behavior) ->
    @item       = $(item)
    @list       = $.map @item.children("[data-behavior~=#{behavior.name}]"), (item, i) ->
      new ListItem(item, behavior)

class @ListItem
  
  constructor: (item, behavior) ->
    @item               = $(item)
    @behavior           = behavior
    @id                 = @item.data("id")
    @drilldown          = @item.find("[data-behavior~=drilldown]").first()
    @auditBehavior      = window.behaviors.find("audit")
    @audits             = @item.find("[data-behavior~=audits]").first()
    @setEvents()

  setEvents: =>
    @drilldown.on "click", @findData
    @audits.on "click", @findAudits

  findData: (event) =>
    event.preventDefault()
    for resource in @behavior.childResources
      @toggleData resource.path, window.behaviors.find(resource.behavior), @drilldown

  findAudits: (event) =>
    event.preventDefault()
    @toggleData @auditBehavior.parentResource, @auditBehavior, @audits

  toggleData: (path, behavior, link) =>
    list = @item.children("[data-behavior~=#{behavior.id}]")
    if list.length
      @toggleList list, link
    else
      @fireAjax path, behavior, link

  fireAjax: (path, behavior, link) =>
    $.ajax
      url: "/#{@behavior.parentResource}/#{@id}/#{path}"
      method: "GET"
      dataType: "HTML"
      success: (data, textStatus, jqXHR) =>
        @handleSuccess(data, behavior, link)
    
  handleSuccess: (results, behavior, link) =>
    html = $(results).find("[data-behavior~=#{behavior.id}]")
    @addBehavior(html, behavior)
    html.appendTo(@item)
    link.html '-'

  addBehavior: (html, behavior) =>
    html.data("behavior", behavior.id)
    new List(html, behavior)

  toggleList: (list, link) =>
    if list.is(":visible")
      list.hide()
      link.html '+'
    else
      if list.find("article").length
        list.show()
        link.html '-'
