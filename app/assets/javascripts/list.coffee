##
# For an element with a particular data behavior will add behavior to each child element
# which has a particular behavior.
# e.g. for element with data-behavior locations-list will add behavior to each drilldown
# for each child element with data-behavior location.
class @List

  constructor: (item, behavior) ->
    @item       = $(item)
    @list       = $.map @item.children("[data-behavior~=#{behavior.name}]"), (item, i) ->
      new ListItem(item, behavior)
      if behavior.info
        new InfoLink(item)

# When the use clicks on the link there will be an Ajax call to retrieve all of the data and this will be output
# below the current link. A new image will be added signifying that the data can be hidden.
# If the user requests for the data to be hidden it will just be hidden so if the user decides they want to see
# it again it does not need to be retrieved again.
class @ListItem
  
  # Attributes:
  #  @item:           The actual html element.
  #  @behavior:       The behavior which was retrieved.
  #  @id:             The data id. Used to retrieve records.
  #  @drilldown:      The element with drilldown behavior attached. A click event will be added.
  #  @auditBehavior:  The audits beavhior retrieved from the window object.
  #  @audits:         The element with audits behavior attached. A click event will be added.
  constructor: (item, behavior) ->
    @item               = $(item)
    @behavior           = behavior
    @id                 = @item.data("id")
    @drilldown          = @item.find("[data-behavior~=drilldown]").first()
    @auditBehavior      = window.behaviors.find("audit")
    @audits             = @item.find("[data-behavior~=audits]").first()
    @setEvents()

  # Add click events for the drilldown and audits elements.
  setEvents: =>
    @drilldown.on "click", @findData
    @audits.on "click", @findAudits

  # For each child resource add the data.
  findData: (event) =>
    event.preventDefault()
    for resource in @behavior.childResources
      @toggleData resource.path, window.behaviors.find(resource.behavior), @drilldown

  # Find audit records for resource.
  findAudits: (event) =>
    event.preventDefault()
    @toggleData @auditBehavior.parentResource, @auditBehavior, @audits

  # Find out if the data has already been added if so show it otherwise find it.
  toggleData: (path, behavior, link) =>
    list = @item.children("[data-behavior~=#{behavior.id}]")
    if list.length
      @toggleList list, link, behavior
    else
      @fireAjax path, behavior, link

  # Fire an Ajax call to retrieve the data using the parent resource, 
  # the data id and the child resource path.
  fireAjax: (path, behavior, link) =>
    $.ajax
      url: "/#{@behavior.parentResource}/#{@id}/#{path}"
      method: "GET"
      dataType: "HTML"
      success: (data, textStatus, jqXHR) =>
        @handleSuccess(data, behavior, link)
  
  # If the data retrieval is successful pull out the relevant data and add it to the html.
  handleSuccess: (results, behavior, link) =>
    html = $(results).find("[data-behavior~=#{behavior.id}]")
    @addBehavior(html, behavior)
    html.appendTo(@item)
    link.html behavior.imageTag.htmlOff

  # Add behavior dynamically to ensure that any data can be added recursively.
  addBehavior: (html, behavior) =>
    html.data("behavior", behavior.id)
    new List(html, behavior)

  # If the data is visible hide it otherwise show it and change the image link accordingly.
  toggleList: (list, link, behavior) =>
    if list.is(":visible")
      list.hide()
      link.html behavior.imageTag.htmlOn
    else
      if list.find("article").length
        list.show()
        link.html behavior.imageTag.htmlOff
