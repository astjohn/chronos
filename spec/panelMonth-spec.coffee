describe "Picker", ->
  givenDate = new Date("2012-05-12")
  options =
    month: givenDate.getMonth()
    givenDate: givenDate
    startDay: 0 # Sunday
    dayNamesAbbr: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
  p = {}

  beforeEach ->
    p = new chronos.PanelMonth(options)

  describe "public methods", ->
    describe "#contructor:", ->
      it "sets @month", ->
        expect(p.month).toEqual(options.month)

      it "sets @givenDate", ->
        expect(p.givenDate.valueOf()).toEqual(options.givenDate.valueOf())

      it "sets @startDay", ->
        expect(p.startDay).toEqual(options.startDay)

      it "sets @today", ->
        expect(p.today.getDate()).toBeTruthy() # duck type

      it "sets @dayNamesAbbr", ->
        expect(p.dayNamesAbbr).toEqual(options.dayNamesAbbr)


    describe "#render", ->
      it "returns a jquery element", ->
        pending


  describe "private methods", ->
    describe "#_getMonthStart", ->
      it "returns a date object", ->
        expect(p._getMonthStart().getDate()).toBeTruthy() # duck type

      it "finds the correct start date", ->
        expect(p._getMonthStart().getDate()).toEqual(29) # should be April 29

      it "finds the correct start date for a weird week start", ->
        p.startDay = 4
        expect(p._getMonthStart().getDate()).toEqual(26) # should be April 26


    describe "#_getMonthHeader", ->
      it "returns a jquery element", ->
        expect(p._getMonthHeader().hide()).toBeTruthy() # duck type

      it "has 7 inner elements", ->
        expect(p._getMonthHeader().children().length).toEqual(7)

      it "has the correct day names", ->
        header = p._getMonthHeader()
        for d in [0..6]
          childText = $(header.children()[d]).html()
          expect(childText).toEqual(p.dayNamesAbbr[d])

      it "can start on a weird day", ->
        p.startDay = 3
        header = p._getMonthHeader()
        childText = $(header.children()[0]).html()
        expect(childText).toEqual(p.dayNamesAbbr[3])


    describe "#_isToday", ->
      today = new Date("2012-05-13 09:22")
      beforeEach ->
        p.today = today

      it "returns true if @today matches the given date", ->
        d = new Date("2012-05-13 11:42")
        expect(p._isToday(d)).toEqual(true)

      it "returns false if @today does not match the given date", ->
        d = new Date("2012-05-15 09:42")
        expect(p._isToday(d)).toEqual(false)

      it "does not mutate today's date", ->
        d = new Date("2012-05-15 09:42")
        p._isToday(d)
        expect(p.today.valueOf()).toEqual(today.valueOf())

      it "does not mutate the given date", ->
        d = new Date("2012-05-15 09:42")
        test = new Date("2012-05-15 09:42")
        p._isToday(d)
        expect(d.valueOf()).toEqual(test.valueOf())


    describe "#_clearTimePortion", ->
      it "clears the hours portion of the given date", ->
        d = new Date("2012-05-15 09:42:32")
        p._clearTimePortion(d)
        expect(d.getHours()).toEqual(0)

      it "clears the minutes portion of the given date", ->
        d = new Date("2012-05-15 09:42:32")
        p._clearTimePortion(d)
        expect(d.getMinutes()).toEqual(0)

      it "clears the milliseconds portion of the given date", ->
        d = new Date("2012-05-15 09:42:32")
        p._clearTimePortion(d)
        expect(d.getMilliseconds()).toEqual(0)


    describe "#_isChoice", ->
      choice = new Date("2012-05-13 09:22")
      beforeEach ->
        p.choice = choice

      it "returns true if the date matches the choice date", ->
        d = new Date("2012-05-13 17:22")
        expect(p._isChoice(d)).toEqual(true)

      it "returns false if the date does not match the choice date", ->
        d = new Date("2012-05-15 17:22")
        expect(p._isChoice(d)).toEqual(false)

      it "returns false if there is no choice", ->
        p.choice = undefined
        expect(p._isChoice(choice)).toEqual(false)


    describe "#_isMonth", ->
      # givenDate = new Date("2012-05-12")
      it "returns true if the given date matches @month", ->
        check = new Date("2012-05-12")
        expect(p._isMonth(check)).toEqual(true)

      it "returns false if the given date does not match @month", ->
        check = new Date("2012-06-12")
        expect(p._isMonth(check)).toEqual(false)


    describe "#_isAvailable", ->
      max = {}
      min = {}
      beforeEach ->
        p.maxDate = undefined
        p.minDate = undefined

      describe "when no max or min date given", ->
        it "returns true", ->
          expect(p._isAvailable()).toEqual(true)

      describe "when both max and min date given", ->
        beforeEach ->
          max = new Date("2012-06-12")
          min = new Date("2012-06-10")
          p.maxDate = max
          p.minDate = min

        it "returns true if date is less than max and more than min", ->
          d = new Date("2012-06-11")
          expect(p._isAvailable(d)).toEqual(true)

        it "returns true if date is equal to max", ->
          d = new Date("2012-06-12")
          expect(p._isAvailable(d)).toEqual(true)

        it "returns true if date is equal to min", ->
          d = new Date("2012-06-10")
          expect(p._isAvailable(d)).toEqual(true)

        it "returns false if date is greater than max", ->
          d = new Date("2012-06-13")
          expect(p._isAvailable(d)).toEqual(false)

        it "returns false if date is less than min", ->
          d = new Date("2012-06-09")
          expect(p._isAvailable(d)).toEqual(false)

      describe "when only max date given", ->
        beforeEach ->
          max = new Date("2012-06-12")
          p.maxDate = max
          p.minDate = undefined

        it "returns true if date is less than max", ->
          d = new Date("2012-06-09")
          expect(p._isAvailable(d)).toEqual(true)

        it "returns true if date is equal to max", ->
          d = new Date("2012-06-12")
          expect(p._isAvailable(d)).toEqual(true)

        it "returns false if date is more than max", ->
          d = new Date("2012-06-13")
          expect(p._isAvailable(d)).toEqual(false)

      describe "when only min date given", ->
        beforeEach ->
          min = new Date("2012-06-10")
          p.maxDate = undefined
          p.minDate = min

        it "returns true if date is more than min", ->
          d = new Date("2012-06-11")
          expect(p._isAvailable(d)).toEqual(true)

        it "returns true if date is equal to min", ->
          d = new Date("2012-06-10")
          expect(p._isAvailable(d)).toEqual(true)

        it "returns false if date is less than min", ->
          d = new Date("2012-06-09")
          expect(p._isAvailable(d)).toEqual(false)


    describe "#_getMonthDays", ->
      it "returns a jquery element", ->
        expect(p._getMonthDays().hide()).toBeTruthy() # duck type

      it "contains the correct number of weeks", ->
        # givenDate = new Date("2012-05-12")
        weeks = p._getMonthDays().find(".week")
        expect(weeks.length).toEqual(6)

      it "contains the correct number of days", ->
        # givenDate = new Date("2012-05-12")
        days = p._getMonthDays().find(".week").children()
        expect(days.length).toEqual(42)


    describe "events", ->
      describe "#_onDaySelect", ->
        p = new chronos.PanelMonth(options)
        p.container = {}
        p.container.trigger = jasmine.createSpy("container")
        mock_event = {target: "mock target element"}
        p._onDaySelect(mock_event, "date")
        expect(p.container.trigger).toHaveBeenCalledWith('daySelect',
          ['mock target element', 'date'])









