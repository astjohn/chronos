describe "Picker", ->
  current = {}
  p = {}

  beforeEach ->
    current.options = chronos.Chronos._defaultOptions
    current.valueElement = "<input type='text' id='ve' name='ve[]' style='display: none;' />"
    current.displayElement = "<input type='text' id='ve_display' />"
    p = new chronos.Picker(current)


  describe "creating a new picker", ->
    it "should set @current", ->
      expect(p.current).toEqual(current)
    it "should call _initialize", ->
      p._initialize = jasmine.createSpy("_initialize")
      p.constructor(current)
      expect(p._initialize).toHaveBeenCalled()

  describe "public methods", ->

    describe "#build", ->
      it "should create a picker container", ->
        p._createContainer = jasmine.createSpy("_createContainer")
        p.build()
        expect(p._createContainer).toHaveBeenCalled()

  describe "private methods", ->

    describe "#_createContainer", ->
      it "should create a jquery container div", ->
        console.log "NOW",
        c = p.build()
        expect(c.hide()).toBeTruthy() # duck type

    describe "#_initialize", ->



