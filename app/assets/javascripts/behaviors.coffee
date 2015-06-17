class @Behaviors

  constructor: (items) ->
    @items = {}
    @createBehaviors(items)

  createBehaviors: (items) ->
    for k,v of items
      @items[k] = new Behavior(name: k, resources: v)

  find: (key) ->
    @items[key]

class @Behavior

  constructor: (item) ->
    @name             = item.name
    @parentResource   = "#{@name}s"
    @id               = "#{@parentResource}-list"
    @childResources   = item.resources