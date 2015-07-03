class @InfoLinks

  constructor: (items) ->
    @items    = $(items)
    $.each @items, (i, item) ->
      new InfoLink(item)

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

