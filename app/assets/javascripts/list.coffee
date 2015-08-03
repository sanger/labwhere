##
# For an element with a particular data behavior will add behavior to each child element
# which has a particular behavior.
# e.g. for element with data-behavior locations-list will add behavior to each drilldown
# for each child element with data-behavior location.
class @List

  constructor: (item) ->
    @item             = $(item)
    @behaviors        = window.behaviors
    @auditsImage      = window.audit
    @drilldownImage   = window.drilldown
    @addListeners()

  addListeners: =>
    self = @
    @item.on "click", "[data-behavior~=drilldown],[data-behavior~=audits],[data-behavior~=info]", (event) ->
      self.triggerEvent($(this), event)

  triggerEvent: (link, event) =>
    event.preventDefault()
    parent = link.closest("[data-behavior~=list]")
    switch link.data("behavior")
      when 'drilldown' then @findData(link, parent)
      when 'audits' then @findAudits(link, parent)
      when 'info' then @toggleInfo(link, parent)

  findData: (link, item) =>
    behavior = @behaviors.find(item.data("type"))
    for resource in behavior.childResources
      @toggleData link, behavior.parentResource, resource, item

  findAudits: (link, item) ->
    behavior = @behaviors.find(item.data("type"))
    @toggleData link, behavior.parentResource, {path: "audits", behavior: "audit"}, item

  toggleData: (link, path, resource, item) ->
    behavior = @behaviors.find(resource.behavior)
    list = item.children("[data-behavior~=#{behavior.id}]")
    if list.length
      @toggleList list, link, behavior
    else
      @fireAjax link, path, resource, item

  toggleList: (list, link, behavior) ->
    image = @findImage(link)
    if list.is(":visible")
      list.hide()
      link.html image.htmlOn
    else
      if list.find("article").length
        list.show()
        link.html image.htmlOff

  fireAjax: (link, path, resource, item) ->
    $.ajax
      url: "/#{path}/#{item.data("id")}/#{resource.path}"
      method: "GET"
      dataType: "HTML"
      success: (data, textStatus, jqXHR) =>
        @handleSuccess(link, data, resource, item)

  handleSuccess: (link, results, resource, item) ->
    behavior = @behaviors.find(resource.behavior)
    html = $(results).find("[data-behavior~=#{behavior.id}]")
    link.html @findImage(link).htmlOff
    html.appendTo(item)

  toggleInfo: (link, parent) ->
    box = parent.find("[data-output~=info-text]")
    rect   = link.position()
    box.css({top: rect.top - $(window).scrollTop(), left: rect.left+30})
    box.toggle()
    box.find("[data-behavior~=close]").on "click", -> box.hide()

  findImage: (link) ->
    if link.data("behavior") is "audits" then @auditsImage else @drilldownImage

jQuery ->
  for list in $("[data-behavior$=-list]")
    new List list
