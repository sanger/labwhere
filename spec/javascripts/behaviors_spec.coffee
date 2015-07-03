
describe "adding behaviors", ->

  beforeAll ->
    @drilldown = new ImageTag({ name: "drilldown", on: "plus", off: "minus", help: "Drilldown" })
    @fixtures = {
      location:{resources:[ { path: "children", behavior: "location"}, { path: "labwares", behavior: "labware"} ], imageTag: @drilldown},
      labware:{resources: [ { path: "histories", behavior: null}], imageTag: @drilldown }
    }

  afterAll ->
    @fixtures = null

  describe "Behavior", ->

    beforeEach ->
      @behavior = new Behavior(name: "location", resources: @fixtures.location.resources, imageTag: @drilldown, info: true)

    it "should exist", ->
      expect(@behavior).toBeDefined()

    it "should create a behaviour name", ->
      expect(@behavior.name).toBe("location")

    it "should create an id which can find the behavior", ->
      expect(@behavior.id).toBe("locations-list")

    it "should create a parent resource", ->
      expect(@behavior.parentResource).toBe("locations")

    it "should create an image tag", ->
      expect(@behavior.imageTag.name).toBe("drilldown")

    it "should create child resources", ->
      children = @behavior.childResources
      expect(children[0].path).toBe("children")
      expect(children[0].behavior).toBe("location")
      expect(children[1].path).toBe("labwares")
      expect(children[1].behavior).toBe("labware")

    it "should be a behavior which will show further information", ->
      expect(@behavior.info).toBe(true)

  describe "Behaviors", ->

    beforeEach ->
      @behaviors = new Behaviors(@fixtures)

    it "should exist", ->
      expect(@behaviors).toBeDefined()

    it "should have two items", ->
      expect(Object.keys(@behaviors.items).length).toEqual(2)

    it "each item should be a behavior", ->
      behavior = @behaviors.find("location")
      expect(behavior.name).toEqual("location")
      expect(behavior.childResources.length).toEqual(2)
      expect(behavior.imageTag).toBe(@drilldown)

      behavior = @behaviors.find("labware")
      expect(behavior.name).toEqual("labware")
      expect(behavior.childResources.length).toEqual(1)
      expect(behavior.imageTag).toBe(@drilldown)

