class @InfoLinks

  constructor: (items) ->
    @items    = $(items)
    $.each @items, (i, item) ->
      new InfoLink(item)

# Some resources contain a Further information link which allows the user to view further information
# about the record. e.g. for a location further information will tell you whether it is active or a container.
# When the use clicks on the link it will show a box containing the info next to the link. This can be toggled.
class @InfoLink

  constructor: (item) ->
    @item   = $(item)
    @info   = @item.find("[data-behavior~=info]")
    @box    = @item.find("[data-behavior~=info-text]")
    @addBehavior()

  addBehavior: =>
    $.each ["info", "close"], (i, element) =>
      @item.find("[data-behavior~=#{element}]").on "click", @toggleInfo

  toggleInfo: (event) =>
    event.preventDefault()
    rect   = @info.position()
    @box.css({top: rect.top - $(window).scrollTop(), left: rect.left+30})
    @box.toggle()

