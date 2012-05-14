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


    describe "#_createBody", ->
      it "should create a jquery container div", ->
        c = p._createBody()
        expect(c.hide()).toBeTruthy() # duck type

      for klass in ["body_prev", "body_curr", "body_next"]
        it "should contain a #{klass} div", ->
          c = p._createBody()
          expect(c.find(".#{klass}").length).toBeGreaterThan(0)


    describe "#_createHeader", ->
      it "should create a jquery container div", ->
        c = p._createHeader()
        expect(c.hide()).toBeTruthy() # duck type

      for klass in ["previous", "title", "next"]
        it "should contain a #{klass} div", ->
          c = p._createHeader()
          expect(c.find(".#{klass}").length).toBeGreaterThan(0)

      it "should handle previous click events", ->
        spyOn(p, '_onPrevious')
        c = p._createHeader()
        c.find(".previous").click()
        expect(p._onPrevious).toHaveBeenCalled()

      it "should handle next click events", ->
        spyOn(p, '_onNext')
        c = p._createHeader()
        c.find(".next").click()
        expect(p._onNext).toHaveBeenCalled()

      it "should handle zoom (title bar) click events", ->
        spyOn(p, '_onZoomOut')
        c = p._createHeader()
        c.find(".title").click()
        expect(p._onZoomOut).toHaveBeenCalled()


    describe "#_initialize", ->

      it "should call _initializeContainer", ->
        p._initializeContainer = jasmine.createSpy("_initializeContainer")
        p.constructor(current)
        expect(p._initializeContainer).toHaveBeenCalled()

      it "should call _setStartingDate", ->
        p._setStartingDate = jasmine.createSpy("_setStartingDate")
        p.constructor(current)
        expect(p._setStartingDate).toHaveBeenCalled()

      it "should set the container", ->
        expect(p.container.find(".body").length).toBeGreaterThan(0) # duck type

      it "creates a new animator", ->
        expect(p.animator).toBeTruthy()


    describe "#_initializeContainer", ->
      it "should call _createContainer", ->
        spyOn(p, '_createContainer').andReturn($("<div class='mock' />"))
        p.constructor(current)
        expect(p._createContainer).toHaveBeenCalled()


    describe "#_renderTitle", ->
      it "should replace the title text", ->
        p._renderTitle("HI")
        expect(p.container.find(".titleText").html()).toEqual("HI")


    describe "#_setStartingDate", ->
      beforeEach ->
        p.current.options.minDate = null
        p.current.options.maxDate = null
        p.startingDate = undefined

      describe "when no maxDate or minDate", ->
        it "sets the startingDate to the @dateToday value", ->
          p._setStartingDate()
          expect(p.startingDate.valueOf()).toEqual(p.todayDate.valueOf())

      describe "when given a minDate", ->

        it "sets the startingDate to the minDate if @todayDate is before the minDate", ->
          min = new Date("2012-06-10")
          p.todayDate = new Date("2012-06-5")
          p.current.options.minDate = min
          p._setStartingDate()
          expect(p.startingDate.valueOf()).toEqual(min.valueOf())

        it "does not set the startingDate if @todayDate is after the minDate", ->
          today = new Date("2012-06-15")
          p.current.options.minDate = new Date("2012-06-10")
          p.todayDate = today
          p._setStartingDate()
          expect(p.startingDate.valueOf()).toEqual(today.valueOf())

      describe "when given a maxDate", ->
        it "sets the startingDate to the maxDate if @todayDate is after the maxDate", ->
          max = new Date("2012-06-10")
          p.todayDate = new Date("2012-06-15")
          p.current.options.maxDate = max
          p._setStartingDate()
          expect(p.startingDate.valueOf()).toEqual(max.valueOf())

        it "does not set the startingDate if @todayDate is before the maxDate", ->
          today = new Date("2012-06-15")
          p.current.options.maxDate = new Date("2012-06-20")
          p.todayDate = today
          p._setStartingDate()
          expect(p.startingDate.valueOf()).toEqual(today.valueOf())

      describe "when given both a minDate and a maxDate", ->
        it "will default to the minDate", ->
          min = new Date("2012-06-10")
          p.todayDate = new Date("2012-06-5")
          p.current.options.minDate = min
          p.current.options.maxDate = new Date("2012-06-20")
          p._setStartingDate()
          expect(p.startingDate.valueOf()).toEqual(min.valueOf())


    describe "#_renderYears", ->
      pending







    describe "#_renderMonths", ->
      d = {}
      $container = {}

      beforeEach ->
        d = new Date("2012-05-10 00:00:00")
        p.startingDate = d

      it "should build the current month", ->
        p._renderMonths()
        c = p.container.find(".body_curr").find(".monthBody").attr("data-date_title")
        expect(c).toEqual("May 2012")

      it "should build the previous month", ->
        p._renderMonths()
        c = p.container.find(".body_prev").find(".monthBody").attr("data-date_title")
        expect(c).toEqual("April 2012")

      it "should build the next month", ->
        p._renderMonths()
        c = p.container.find(".body_next").find(".monthBody").attr("data-date_title")
        expect(c).toEqual("June 2012")


    describe "#_buildMonth", ->
      d = new Date()
      $container = $("<div />")

      it "should add a month panel to the given container", ->
        p._buildMonth(d, $container)
        expect($container.find(".monthPanel").length).toEqual(1)

      it "should handle day click events", ->
        spyOn(p, '_onDaySelect')
        $test = p._buildMonth(d, $container)
        $day = $test.find(".monthBody").find(".week0").find(".day0")
        $day.click()
        expect(p._onDaySelect).toHaveBeenCalled()


    describe "#_changeMonthBy", ->
      d = {}
      beforeEach ->
        d = new Date()

      it "returns a date object", ->
        expect(p._changeMonthBy(d, 0).valueOf()).toBeTruthy() # duck type

      it "can decrease the given date by given months", ->
        test = new Date(d.valueOf())
        test.setMonth(d.getMonth() - 2)
        expect(p._changeMonthBy(d, -2).valueOf()).toEqual(test.valueOf())

      it "can increase the given date by given months", ->
        test = new Date(d.valueOf())
        test.setMonth(d.getMonth() + 5)
        expect(p._changeMonthBy(d, 5).valueOf()).toEqual(test.valueOf())


    describe "events", ->
      event = {}
      beforeEach ->
        event = {target: "mock"}
        spyOn(event, 'target')

      describe "_onPrevious", ->
        it "should tell the animator which picker to use", ->
          spyOn(p.animator, 'setPicker')
          spyOn(p.animator, 'previousMonth')
          p._onPrevious(event)
          expect(p.animator.setPicker).toHaveBeenCalled()

        it "should animate the previous month action", ->
          spyOn(p.animator, 'setPicker')
          spyOn(p.animator, 'previousMonth')
          p._onPrevious(event)
          expect(p.animator.previousMonth).toHaveBeenCalled()

      describe "_onNext", ->
        it "should tell the animator which picker to use", ->
          spyOn(p.animator, 'setPicker')
          spyOn(p.animator, 'nextMonth')
          p._onNext(event)
          expect(p.animator.setPicker).toHaveBeenCalled()

        it "should animate the previous month action", ->
          spyOn(p.animator, 'setPicker')
          spyOn(p.animator, 'nextMonth')
          p._onNext(event)
          expect(p.animator.nextMonth).toHaveBeenCalled()




