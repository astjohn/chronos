describe "Picker", ->
  current = {}
  p = {}

  beforeEach ->
    current.options = chronos.Chronos._defaultOptions
    current.valueElement = "<input type='text' id='ve' name='ve[]' style='display: none;' />"
    current.displayElement = "<input type='text' id='ve_display' />"
    current.pickedDateTime = undefined
    p = new chronos.Picker(current)


  describe "creating a new picker", ->
    it "should set @current", ->
      expect(p.current).toEqual(current)

    it "should set @todayDate", ->
      expect(p.todayDate.getDate()).toBeTruthy() # duck type

    it "should set @current.pickedDateTime", ->
      current.pickedDateTime = new Date()
      x = new chronos.Picker(current)
      expect(x.current.pickedDateTime.getDate()).toBeTruthy() # duck type

    it "should set the @$valueElment", ->
      expect(p.$valueElement.hide()).toBeTruthy() # duck type

    it "should set the @$displayElment", ->
      expect(p.$displayElement.hide()).toBeTruthy() # duck type

    it "should set @dateFormatter to be a new dateFormatter", ->
      expect(p.dateFormatter.format()).toBeTruthy # duck type

    it "should call _initialize", ->
      p._initialize = jasmine.createSpy("_initialize")
      p.constructor(current)
      expect(p._initialize).toHaveBeenCalled()


  describe "public methods", ->

    describe "#render", ->
      it "renders years when @mode is 'year'", ->
        spyOn(p, "_renderYears")
        p.mode = 'year'
        p.render()
        expect(p._renderYears).toHaveBeenCalled()

      it "renders time when @mode is 'time", ->
        spyOn(p, "_renderTime")
        p.mode = 'time'
        p.render()
        expect(p._renderTime).toHaveBeenCalled()

      it "renders months otherwise", ->
        spyOn(p, "_renderMonths")
        p.mode = null
        p.render()
        expect(p._renderMonths).toHaveBeenCalled()

      it "calls #_emptyBody", ->
        spyOn(p, "_emptyBody")
        p.render()
        expect(p._emptyBody).toHaveBeenCalled()


    describe "#close", ->
      it "calls the animator's close method", ->
        spyOn(p.animator, 'close')
        p.close()
        expect(p.animator.close).toHaveBeenCalled()


    describe "#insertAfter", ->
      element = {}
      beforeEach ->
        spyOn(p.animator, 'open')
        spyOn(p, 'setPosition')
        element =
          after: "whatever"
        spyOn(element, 'after')

      it "places the picker after the given element", ->
        p.insertAfter(element)
        expect(element.after).toHaveBeenCalledWith(p.$container)

      it "calls #setPosition", ->
        p.insertAfter(element)
        expect(p.setPosition).toHaveBeenCalled()

      it "calls #open on the animator", ->
        p.insertAfter(element)
        expect(p.animator.open).toHaveBeenCalled()


    describe "#setPosition", ->
      chain =
        css: "jquery chain mock"
      beforeEach ->
        spyOn(chain, 'css')
        spyOn(p.$container, 'css').andReturn(chain)

      it "should set the position to absolute", ->
        spyOn(p, '_getPosition')
        p.setPosition()
        expect(chain.css).toHaveBeenCalledWith({position: 'absolute'})

      describe "without given position", ->
        it "should call #_getPosition", ->
          spyOn(p, '_getPosition')
          p.setPosition()
          expect(p._getPosition).toHaveBeenCalled()

      describe "when given a position", ->
        it "should use the position", ->
          pos = {top: 30, left: 50}
          p.setPosition(pos)
          expect(p.$container.css).toHaveBeenCalledWith(pos)

        it "should not call #_getPosition", ->
          spyOn(p, '_getPosition')
          p.setPosition({top: 20, left: 50})
          expect(p._getPosition).not.toHaveBeenCalled()


    describe "setDate", ->
      beforeEach ->
        spyOn(p, '_saveDate')
        spyOn(p, '_updateInputValues')

      describe "when given an invalid date", ->
        it "doesn't do anything", ->
          p.setDate("not valid")
          expect(p._saveDate).not.toHaveBeenCalled()

      describe "when given a valid date", ->
        d = {}
        beforeEach ->
          d = new Date()
          p.setDate(d)

        it "saves the date", ->
          expect(p._saveDate).toHaveBeenCalledWith(d)

        it "calls _updateInputValues", ->
          expect(p._updateInputValues).toHaveBeenCalled()


    describe "checkAndSetDate", ->

      describe "when invalid date", ->
        beforeEach ->
          spyOn(p.dateFormatter, 'unformat').andReturn(false)

        it "triggers the 'invalidDate event", ->
          spyOn(p.$container, 'trigger')
          p.checkAndSetDate()
          expect(p.$container.trigger).toHaveBeenCalledWith('invalidDate')

      describe "when valid date", ->
        d = {}
        beforeEach ->
          d = new Date()
          spyOn(p.dateFormatter, 'unformat').andReturn(d)
          spyOn(p, '_saveDate')
          spyOn(p, '_updateValueElement')
          spyOn(p.$container, 'trigger')
          spyOn(p, 'render')
          p.checkAndSetDate()

        it "saves the date", ->
          expect(p._saveDate).toHaveBeenCalledWith(d)

        it "updates the value element", ->
          expect(p._updateValueElement).toHaveBeenCalled()

        it "triggers the 'validDate' event", ->
          expect(p.$container.trigger).toHaveBeenCalledWith('validDate')

        it "re-renders the picker", ->
          expect(p.render).toHaveBeenCalled()

      it "calls unformat on the dateFormatter to try to create a date", ->
        spyOn(p.dateFormatter, 'unformat').andReturn(false)
        p.checkAndSetDate()
        expect(p.dateFormatter.unformat).toHaveBeenCalled()


    describe "setDateRange", ->
      beforeEach ->
        p.current.options =
          minDate: undefined
          maxDate: undefined
        spyOn(p, 'render')

      it "calls @render", ->
        p.setDateRange("whatever")
        expect(p.render).toHaveBeenCalled()

      describe "when given nonsense", ->
        beforeEach ->
          p.setDateRange("what?")

        it "does not set the minDate", ->
          expect(p.current.options.minDate).toEqual(undefined)

        it "does not set the maxDate", ->
          expect(p.current.options.minDate).toEqual(undefined)

      describe "when given a minDate", ->
        d = new Date()
        range = {}
        beforeEach ->
          range =
            minDate: d

        it "sets the minDate if valid", ->
          spyOn(p, '_isValidDate').andReturn(true)
          spyOn(p, '_saveSettings')
          p.setDateRange(range)
          expect(p.current.options.minDate.valueOf()).toEqual(d.valueOf())

        it "saves the settings if valid", ->
          spyOn(p, '_isValidDate').andReturn(true)
          spyOn(p, '_saveSettings')
          p.setDateRange(range)
          expect(p._saveSettings).toHaveBeenCalled()

        it "does not set the minDate if not valid", ->
          spyOn(p, '_isValidDate').andReturn(false)
          p.setDateRange(range)
          expect(p.current.options.minDate).toEqual(undefined)

        it "displays a console warning if minDate is not valid", ->
          spyOn(p, '_isValidDate').andReturn(false)
          spyOn(console, 'warn')
          p.setDateRange(range)
          expect(console.warn).toHaveBeenCalled()

      describe "when given a maxDate", ->
        d = new Date()
        range = {}
        beforeEach ->
          range =
            maxDate: d

        it "sets the maxDate if valid", ->
          spyOn(p, '_isValidDate').andReturn(true)
          spyOn(p, '_saveSettings')
          p.setDateRange(range)
          expect(p.current.options.maxDate.valueOf()).toEqual(d.valueOf())

        it "saves the settings if valid", ->
          spyOn(p, '_isValidDate').andReturn(true)
          spyOn(p, '_saveSettings')
          p.setDateRange(range)
          expect(p._saveSettings).toHaveBeenCalled()

        it "does not set the maxDate if not valid", ->
          spyOn(p, '_isValidDate').andReturn(false)
          p.setDateRange(range)
          expect(p.current.options.maxDate).toEqual(undefined)

        it "displays a console warning if maxDate is not valid", ->
          spyOn(p, '_isValidDate').andReturn(false)
          spyOn(console, 'warn')
          p.setDateRange(range)
          expect(console.warn).toHaveBeenCalled()




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
      beforeEach ->
        spyOn(p, '_initializeContainer')
        spyOn(p, '_initializeAnimator')
        spyOn(p, '_setStartingDate')
        spyOn(p, '_setPickedDate')
        spyOn(p, '_setInitialMode')

      it "should call #_initializeContainer", ->
        p.constructor(current)
        expect(p._initializeContainer).toHaveBeenCalled()

      it "should call #_initializeAnimator", ->
        p.constructor(current)
        expect(p._initializeAnimator).toHaveBeenCalled()

      it "should call #_setStartingDate", ->
        p.constructor(current)
        expect(p._setStartingDate).toHaveBeenCalled()

      it "should call #_setPickedDate", ->
        p.constructor(current)
        expect(p._setPickedDate).toHaveBeenCalled()

      it "should call #_setInitialMode", ->
        p.constructor(current)
        expect(p._setInitialMode).toHaveBeenCalled()


    describe "#_initializeAnimator", ->
      beforeEach ->
        spyOn(chronos.Animator, 'constructor')

      it "creates a new animator", ->
        p._initializeAnimator()
        expect(p.animator).toBeTruthy()

      it "should tell the animator which picker to use", ->
        p._initializeAnimator()
        expect(p.animator.$picker).toBe(p.$container)


    describe "#_setInitialMode", ->
      describe "for time picker", ->
        it "sets the mode to 'time' if options are good", ->
          p.current.options.useTimePicker = true
          p.current.options.timePickerOnly = true
          p._setInitialMode()
          expect(p.mode).toEqual('time')

        it "does not set the mode to 'time' if missing useTimePicker option", ->
          p.current.options.useTimePicker = undefined
          p.current.options.timePickerOnly = true
          p._setInitialMode()
          expect(p.mode).not.toEqual('time')

        it "does not set the mode to 'time' if missing timePickerOnly", ->
          p.current.options.useTimePicker = true
          p.current.options.timePickerOnly = undefined
          p._setInitialMode()
          expect(p.mode).not.toEqual('time')

      describe "for years only", ->
        it "sets the mode to 'year' if given yearOnly option", ->
          p.current.options.yearOnly = true
          p._setInitialMode()
          expect(p.mode).toEqual('year')

        it "does not set the mode to 'year' if missing yearOnly", ->
          p.current.options.yearOnly = undefined
          p._setInitialMode()
          expect(p.mode).not.toEqual('year')

      describe "otherwise", ->
        it "sets mode to 'month", ->
          p.current.options.yearOnly = undefined
          p.current.options.useTimePicker = undefined
          p._setInitialMode()
          expect(p.mode).toEqual('month')


    describe "#_initializeContainer", ->
      beforeEach ->
        spyOn(p, '_bindContainerEvents')
        spyOn(p, '_createContainer').andReturn($("<div class='mock' />"))

      it "should call _createContainer", ->
        p.constructor(current)
        expect(p._createContainer).toHaveBeenCalled()

      it "should call _bindContainerEvents", ->
        p.constructor(current)
        expect(p._bindContainerEvents).toHaveBeenCalled()

      it "should set the container", ->
        p.constructor(current)
        expect(p.$container.find(".body").length).toBeGreaterThan(0) # duck type


    describe "#_emptyBody", ->
      beforeEach ->
        p.$container = $("<div><div class='body_curr'>text</div>
                         <div class='body_next'>text</div>
                         <div class='body_prev'>text</div>")
        p._emptyBody()
      it "should empty the 'body_curr' div", ->
        expect(p.$container.find('.body_curr').html()).toEqual("")
      it "should empty the 'body_next' div", ->
        expect(p.$container.find('.body_next').html()).toEqual("")
      it "should empty the 'body_prev' div", ->
        expect(p.$container.find('.body_prev').html()).toEqual("")

    describe "#_renderTitle", ->
      it "should replace the title text", ->
        p._renderTitle("HI")
        expect(p.$container.find(".titleText").html()).toEqual("HI")


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


    describe "#_setPickedDate", ->
      describe "when allowed to start blank", ->
        it "does not set the pickedDateTime", ->
          p.current.pickedDateTime = null
          p.current.options.startBlank = true
          p._setPickedDate()
          expect(p.pickedDateTime).toEqual(null)

      describe "when not allowed to start blank", ->
        it "does not mess around if a pickedDateTime already exists", ->
          d = Date.parse("2011-04-22")
          p.current.pickedDateTime = d
          p.current.options.startBlank = false
          p.startingDate = Date.parse("2011-04-30")
          p._setPickedDate()
          expect(p.current.pickedDateTime.valueOf()).toEqual(d.valueOf())

        it "sets the pickedDateTime to the startingDate if undefined", ->
          d = Date.parse("2011-04-22")
          p.current.pickedDateTime = undefined
          p.current.options.startBlank = false
          p.startingDate = d
          p._setPickedDate()
          expect(p.current.pickedDateTime.valueOf()).toEqual(d.valueOf())

  #     # set's the pickers picked date if need be
  # _setPickedDate: ->
  #   unless @current.options.startBlank
  #     @pickedDateTime = new Date(@startingDate.valueOf()) unless @pickedDateTime


    describe "#_renderYears", ->
      pending

    describe "#_renderTime", ->
      pending



    describe "#_renderMonths", ->
      d = {}
      $container = {}

      describe "when no pickedDateTime", ->
        beforeEach ->
          p.current.pickedDateTime = undefined
          p.startingDate = new Date("2012-05-10 00:00:00")

        it "should build the current month", ->
          p._renderMonths()
          c = p.$container.find(".body_curr").find(".monthBody").attr("data-date_title")
          expect(c).toEqual("May 2012")

        it "should build the previous month", ->
          p._renderMonths()
          c = p.$container.find(".body_prev").find(".monthBody").attr("data-date_title")
          expect(c).toEqual("April 2012")

        it "should build the next month", ->
          p._renderMonths()
          c = p.$container.find(".body_next").find(".monthBody").attr("data-date_title")
          expect(c).toEqual("June 2012")

      describe "when pickedDateTime", ->
        beforeEach ->
          p.startingDate = new Date("2012-05-10 00:00:00")
          p.current.pickedDateTime = new Date("2013-06-15 00:00:00")

        it "should build the current month for the pickedDateTime", ->
          p._renderMonths()
          c = p.$container.find(".body_curr").find(".monthBody").attr("data-date_title")
          expect(c).toEqual("June 2013")

        it "should build the previous month for the pickedDateTime", ->
          p._renderMonths()
          c = p.$container.find(".body_prev").find(".monthBody").attr("data-date_title")
          expect(c).toEqual("May 2013")

        it "should build the next month for the pickedDateTime", ->
          p._renderMonths()
          c = p.$container.find(".body_next").find(".monthBody").attr("data-date_title")
          expect(c).toEqual("July 2013")


    describe "#_buildMonth", ->
      d = new Date()
      $container = $("<div />")

      it "should add a month panel to the given container", ->
        p._buildMonth(d, $container)
        expect($container.find(".monthPanel").length).toEqual(1)

      # TODO: This test works in isolation, but not during full suite
      # it "should handle day click events", ->
      #   spyOn(p, '_onDaySelect')
      #   $test = p._buildMonth(d, $container)
      #   $day = $test.find(".monthBody").find(".week0").find(".day0")
      #   $day.click()
      #   expect(p._onDaySelect).toHaveBeenCalled()


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


    describe "#_saveSettings", ->
      it "uses jquery $.data to save settings for the displayElement", ->
        spyOn($, 'data')
        p._saveSettings()
        expect($.data).toHaveBeenCalledWith(p.current.displayElement,
          chronos.Chronos.PROP_NAME, p.current)


    describe "#_updateInputValues", ->
      beforeEach ->
        spyOn(p, '_updateValueElement')
        spyOn(p, '_updateDisplayElement')

      it "updates the value element", ->
        p._updateInputValues()
        expect(p._updateValueElement).toHaveBeenCalled()

      it "updates the display element", ->
        p._updateInputValues()
        expect(p._updateDisplayElement).toHaveBeenCalled()


    describe "#_updateDisplayElement", ->
      beforeEach ->
        spyOn(p.dateFormatter, 'format').andReturn("a date")

      describe "when a datetime has been picked", ->
        beforeEach ->
          p.current.pickedDateTime = new Date()

        it "asks dateFormatter for a pretty string representation", ->
          p._updateDisplayElement()
          expect(p.dateFormatter.format).toHaveBeenCalledWith(p.current.pickedDateTime,
            p.current.options.displayFormat)

        it "changes the display elements value", ->
          p._updateDisplayElement()
          expect(p.$displayElement.val()).toEqual("a date")

      describe "when a datetime has not been picked", ->
        beforeEach ->
          p.current.pickedDateTime = undefined

        it "does not call the dateFormatter", ->
          p._updateDisplayElement()
          expect(p.dateFormatter.format).not.toHaveBeenCalled()

        it "does not update the display element", ->
          p._updateDisplayElement()
          expect(p.$displayElement.val()).toEqual("")


    describe "#_updateValueElement", ->
      beforeEach ->
        spyOn(p.dateFormatter, 'format').andReturn("a date")

      describe "when a datetime has been picked", ->
        beforeEach ->
          p.current.pickedDateTime = new Date()

        it "asks dateFormatter for a pretty string representation", ->
          p._updateValueElement()
          expect(p.dateFormatter.format).toHaveBeenCalledWith(p.current.pickedDateTime,
            p.current.options.valueFormat)

        it "changes the display elements value", ->
          p._updateValueElement()
          expect(p.$valueElement.val()).toEqual("a date")

      describe "when a datetime has not been picked", ->
        beforeEach ->
          p.current.pickedDateTime = undefined

        it "does not call the dateFormatter", ->
          p._updateValueElement()
          expect(p.dateFormatter.format).not.toHaveBeenCalled()

        it "does not update the display element", ->
          p._updateValueElement()
          expect(p.$valueElement.val()).toEqual("")


    describe "#_getWindowHeight", ->
    describe "#_getScrollTop", ->
      # TODO: How to spy on $(whatever) objects?


    describe "#_getPosition", ->
      dePosition = {}
      deOuterHeight = {}
      docHeight = {}
      pickerHeight = {}
      beforeEach ->
        deOuterHeight = 16
        pickerHeight = 150
        p.current.options =
          positionOffset:
            top: 0
            left: 0
        spyOn(p.$displayElement, 'outerHeight').andReturn(deOuterHeight)
        spyOn(p.$container, 'outerHeight').andReturn(pickerHeight)

      describe "for above and below", ->
        beforeEach ->
          dePosition =
            top: 200
            left: 10
          spyOn(p.$displayElement, 'offset').andReturn(dePosition)

        describe "when there is enough room to display below", ->
          # Picker @ 200 + height @ 150 = 350 vs. 1000
          it "sets position top to just below the displayElement", ->
            spyOn(p, '_getWindowHeight').andReturn(1000)
            spyOn(p, '_getScrollTop').andReturn(20)
            f = p._getPosition()
            expect(f.top).toEqual(dePosition.top + deOuterHeight)

        describe "when there is only room to display above", ->
          # Picker @ 200 + height @ 150 = 350 vs. 1000
          it "sets the position top to above the displayElement", ->
            spyOn(p, '_getWindowHeight').andReturn(200)
            spyOn(p, '_getScrollTop').andReturn(0)
            f = p._getPosition()
            expect(f.top).toEqual(dePosition.top - p.$container.outerHeight())

      describe "not above or below", ->
        beforeEach ->
          dePosition =
            top: 100
            left: 10
          spyOn(p.$displayElement, 'offset').andReturn(dePosition)

        describe "when there is not enough room for above or below", ->
          it "sets the picker in the center of the available vertical", ->
            # Picker @ 100 but its height is 150. vs 200 vertical
            spyOn(p, '_getWindowHeight').andReturn(200)
            spyOn(p, '_getScrollTop').andReturn(0)
            f = p._getPosition()
            expect(f.top).toEqual(200 / 2 - 150 / 2)

        describe "when there is not enough room at all", ->
          beforeEach ->
            # Picker @ 100 but its height is 150. vs 75 vertical
            spyOn(p, '_getWindowHeight').andReturn(75)
            spyOn(p, '_getScrollTop').andReturn(0)

          it "sets the picker in the center of the available vertical", ->
            f = p._getPosition()
            expect(f.top).toEqual(75 / 2 - 150 / 2)

          it "displays a console warning", ->
            spyOn(console, 'warn')
            f = p._getPosition()
            expect(console.warn).toHaveBeenCalled()


    describe "#_isValidDate", ->
      it "returns true if given a date object", ->
        expect(p._isValidDate(new Date())).toEqual(true)

      it "returns false if given a different type of object", ->
        expect(p._isValidDate({whatever: "something"})).toEqual(false)


    describe "#_saveDate", ->
      d = {}
      beforeEach ->
        d = new Date()
        spyOn(p, '_saveSettings')

      it "sets the current pickedDateTime", ->
        p._saveDate(d)
        expect(p.current.pickedDateTime).toBe(d)

      it "saves the settings", ->
        p._saveDate(d)
        expect(p._saveSettings).toHaveBeenCalled()



    describe "events", ->
      event = {}
      beforeEach ->
        event = {target: "mock"}
        spyOn(event, 'target')

      describe "#_onPrevious", ->
        it "should animate the previous month action", ->
          spyOn(p.animator, 'previousMonth')
          p._onPrevious(event)
          expect(p.animator.previousMonth).toHaveBeenCalled()


      describe "#_onNext", ->
        it "should animate the previous month action", ->
          spyOn(p.animator, 'nextMonth')
          p._onNext(event)
          expect(p.animator.nextMonth).toHaveBeenCalled()


      describe "#_onDaySelected", ->
        date = new Date("2012-10-05")
        dayElement = $('<div class="day day3">9</div>')
        event = jasmine.createSpy("jquery event mock")
        beforeEach ->
          spyOn(p, '_saveSettings')
          spyOn(p, '_updateInputValues')
          spyOn(p, 'close')

        describe "when not using time picker", ->

          it "sets @current.pickedDateTime", ->
            p._onDaySelected(event, dayElement, date)
            expect(p.current.pickedDateTime).toBe(date)

          it "saves settings", ->
            p._onDaySelected(event, dayElement, date)
            expect(p._saveSettings).toHaveBeenCalled()

          it "updates the inputs", ->
            p._onDaySelected(event, dayElement, date)
            expect(p._updateInputValues).toHaveBeenCalled()

          it "tiggers 'internal_close' to let Chronos manage the closing process", ->
            spyOn(p.$container, 'trigger')
            p._onDaySelected(event, dayElement, date)
            expect(p.$container.trigger).toHaveBeenCalledWith('internal_close')

        describe "when using time picker", ->
          pending


      describe "_passEvents", ->
        e = {type: "mock event"}
        e.stopPropagation = jasmine.createSpy('stop propagation mock')
        args = "some arguments"

        it "should trigger the given event on the valueElement", ->
          p.$valueElement.trigger = jasmine.createSpy("trigger mock")
          p._passEvents(e, args)
          expect(p.$valueElement.trigger).toHaveBeenCalledWith(e.type, args)

        it "should stop propagation", ->
          p._passEvents(e, args)
          expect(e.stopPropagation).toHaveBeenCalled()





