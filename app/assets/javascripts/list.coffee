##
# For an element with a particular data behavior will add behavior to each child element
# which has a particular behavior.
# e.g. for element with data-behavior locations-list will add behavior to each drilldown
# for each child element with data-behavior location.
class @List

  constructor: (item, behavior) ->
    @item           = $(item)
    @behavior       = behavior
    @auditBehavior  = window.behaviors.find("audit")
    @addBehaviors()

  addBehaviors: =>
    for item in @item.children("[data-behavior~=#{@behavior.name}]")
      @setEvents($(item))

  setEvents: (item) =>
    drilldown = item.find("[data-behavior~=drilldown]").first()
    drilldown.on("click", {id: item.data("id"), link: drilldown, item: item}, @findData)
    if @behavior.audits
      audits = item.find("[data-behavior~=audits]").first()
      audits.on("click", {id: item.data("id"), link: audits, item: item}, @findAudits)
    if @behavior.info
      @addInfo(item)

  findData: (event) =>
    event.preventDefault()
    for resource in @behavior.childResources
      @toggleData resource.path, window.behaviors.find(resource.behavior), event

  findAudits: (event) =>
    event.preventDefault()
    @toggleData @auditBehavior.parentResource, @auditBehavior, event

  addInfo: (item) =>
    box = item.find("[data-behavior~=info-text]")
    info = item.find("[data-behavior~=info]")
    info.on("click", {info: info, box: box}, @toggleInfo)
    close = item.find("[data-behavior~=close]")
    close.on("click", {info: close, box: box}, @toggleInfo)

  toggleData: (path, behavior, event) =>
    list = event.data.item.children("[data-behavior~=#{behavior.id}]")
    if list.length
      @toggleList list, event.data.link, behavior
    else
      @fireAjax path, behavior, event

  toggleList: (list, link, behavior) =>
    if list.is(":visible")
      list.hide()
      link.html behavior.imageTag.htmlOn
    else
      if list.find("article").length
        list.show()
        link.html behavior.imageTag.htmlOff

  fireAjax: (path, behavior, event) =>
    $.ajax
      url: "/#{@behavior.parentResource}/#{event.data.id}/#{path}"
      method: "GET"
      dataType: "HTML"
      success: (data, textStatus, jqXHR) =>
        @handleSuccess(data, behavior, event)

  handleSuccess: (results, behavior, event) =>
    html = $(results).find("[data-behavior~=#{behavior.id}]")
    event.data.link.html behavior.imageTag.htmlOff
    html.appendTo(event.data.item)
    @addBehavior(html, behavior)

  addBehavior: (html, behavior) =>
    html.data("behavior", behavior.id)
    new List(html, behavior)

  toggleInfo: (event) =>
    event.preventDefault()
    rect   = event.data.info.position()
    event.data.box.css({top: rect.top - $(window).scrollTop(), left: rect.left+30})
    event.data.box.toggle()

