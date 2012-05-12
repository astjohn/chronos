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

    it "should set @todayDate", ->
      expect(p.todayDate.getDate()).toBeTruthy() # duck type

    # it "should set @pickedDate", ->
    #   expect(p.pickedDate.getDate()).toBeTruthy() # duck type

    it "should call _initialize", ->
      p._initialize = jasmine.createSpy("_initialize")
      p.constructor(current)
      expect(p._initialize).toHaveBeenCalled()


  describe "public methods", ->



  describe "private methods", ->

    describe "#_createContainer", ->
      it "should create a jquery container div", ->
        c = p._createContainer()
        expect(c.hide()).toBeTruthy() # duck type

      it "should always add 'chronos_picker' to the class", ->
        c = p._createContainer()
        expect(c.hasClass('chronos_picker')).toBeTruthy

      it "should add the pickerClass if there is one", ->
        c = p._createContainer()
        expect(c.hasClass('blue')).toBeTruthy


    describe "#_createHeader", ->
      it "should create a jquery container div", ->
        c = p._createBody()
        expect(c.hide()).toBeTruthy() # duck type

      for klass in ["body_prev", "body_curr", "body_next"]
        it "should contain a #{klass} div", ->
          c = p._createBody()
          expect(c.find(".#{klass}").length).toBeGreaterThan(0)


    describe "#_createBody", ->
      it "should create a jquery container div", ->
        c = p._createHeader()
        expect(c.hide()).toBeTruthy() # duck type

      for klass in ["previous", "title", "next", "close"]
        it "should contain a #{klass} div", ->
          c = p._createHeader()
          expect(c.find(".#{klass}").length).toBeGreaterThan(0)


    describe "#_initialize", ->

      it "should call _initializeContainer", ->
        p._initializeContainer = jasmine.createSpy("_initializeContainer")
        p.constructor(current)
        expect(p._initializeContainer).toHaveBeenCalled()

      it "should call _setWorkingDate", ->
        p._setWorkingDate = jasmine.createSpy("_setWorkingDate")
        p.constructor(current)
        expect(p._setWorkingDate).toHaveBeenCalled()

      it "should set the container", ->
        expect(p.container.find(".body").length).toBeGreaterThan(0) # duck type


    describe "#_initializeContainer", ->
      it "should call _createContainer", ->
        spyOn(p, '_createContainer').andReturn($("<div class='mock' />"))
        p.constructor(current)
        expect(p._createContainer).toHaveBeenCalled()


    describe "#_renderTitle", ->
      it "should replace the title text", ->
        p._renderTitle("HI")
        expect(p.container.find(".titleText").html()).toEqual("HI")

    describe "#_setWorkingDate", ->
      console.log "SWD"
      beforeEach ->
        p.current.options.minDate = null
        p.current.options.maxDate = null
        p.workingDate = undefined

      describe "when no maxDate or minDate", ->
        it "sets the workingDate to the @dateToday value", ->
          p._setWorkingDate()
          expect(p.workingDate.valueOf()).toEqual(p.todayDate.valueOf())

      describe "when given a minDate", ->

        it "sets the workingDate to the minDate if @todayDate is before the minDate", ->
          min = new Date("2012-06-10")
          p.todayDate = new Date("2012-06-5")
          p.current.options.minDate = min
          p._setWorkingDate()
          expect(p.workingDate.valueOf()).toEqual(min.valueOf())

        it "does not set the workingDate if @todayDate is after the minDate", ->
          today = new Date("2012-06-15")
          p.current.options.minDate = new Date("2012-06-10")
          p.todayDate = today
          p._setWorkingDate()
          expect(p.workingDate.valueOf()).toEqual(today.valueOf())

      describe "when given a maxDate", ->
        it "sets the workingDate to the maxDate if @todayDate is after the maxDate", ->
          max = new Date("2012-06-10")
          p.todayDate = new Date("2012-06-15")
          p.current.options.maxDate = max
          p._setWorkingDate()
          expect(p.workingDate.valueOf()).toEqual(max.valueOf())

        it "does not set the workingDate if @todayDate is before the maxDate", ->
          today = new Date("2012-06-15")
          p.current.options.maxDate = new Date("2012-06-20")
          p.todayDate = today
          p._setWorkingDate()
          expect(p.workingDate.valueOf()).toEqual(today.valueOf())

      describe "when given both a minDate and a maxDate", ->
        it "will default to the minDate", ->
          min = new Date("2012-06-10")
          p.todayDate = new Date("2012-06-5")
          p.current.options.minDate = min
          p.current.options.maxDate = new Date("2012-06-20")
          p._setWorkingDate()
          expect(p.workingDate.valueOf()).toEqual(min.valueOf())


    describe "#_renderYears", ->
      pending







    describe "#_renderMonths", ->
      pending

