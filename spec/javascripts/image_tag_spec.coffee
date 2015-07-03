
describe "adding image tags", ->

  beforeAll ->
    @fixtures = { name: "drilldown", on: "plus", off: "minus", help: "Drilldown" }

  afterAll ->
    @fixtures = null

  describe "ImageTag", ->

    beforeEach ->
      @imageTag = new ImageTag(@fixtures)

    it "should exist", ->
      expect(@imageTag).toBeDefined()

    it "should create an image tag name", ->
      expect(@imageTag.name).toBe("drilldown")

    it "should create a filename for the on", ->
      expect(@imageTag.filenameOn).toBe("plus.png")

    it "should create a filename for the off", ->
      expect(@imageTag.filenameOff).toBe("minus.png")

    it "should create an alt", ->
      expect(@imageTag.alt).toBe("Drilldown")

    it "should create a title", ->
      expect(@imageTag.title).toBe("Drilldown")

    it "should create a html link for the on", ->
      expect(@imageTag.htmlOn).toBe("<img src='#{image_path('plus.png')}' alt='Drilldown' title='Drilldown' />")

    it "should create a html link for the off", ->
      expect(@imageTag.htmlOff).toBe("<img src='#{image_path('minus.png')}' alt='Drilldown' title='Drilldown' />")