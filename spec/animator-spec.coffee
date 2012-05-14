describe "Animator", ->
  a = {}
  options = {}
  pm = {}

  beforeEach ->
    pm = jasmine.createSpy("mock picker")
    a = new chronos.Animator(pm, options)

  describe "#constructor", ->

    it "should set the pickerManager", ->
      expect(a.pickerManager).toEqual(pm)

    it "should set the animation options", ->
      opts = {some: "options"}
      a = new chronos.Animator(pm, opts)
      expect(a.animations).toBe(opts)


  describe "#setPicker", ->
    it "sets @$picker to the given value", ->
      spyOn(a, '_setElements')
      a.setPicker("something")
      expect(a.$picker).toEqual("something")

    it "calls @_setElements", ->
      spyOn(a, '_setElements')
      a.setPicker("something")
      expect(a._setElements).toHaveBeenCalled()


  describe "#previousMonth", ->
    describe "when given custom animations", ->
      pmp = jasmine.createSpy("previousMonthPrepare mock")
      pma = jasmine.createSpy("previousMonth mock")
      pmc = jasmine.createSpy("previousMonthCallback mock")
      beforeEach ->
        options =
          previousMonthPrepare: pmp
          previousMonth: pma
          previousMonthCallback: pmc
        a = new chronos.Animator(pm, options)

      it "calls animate with the correct arguments", ->
        spyOn(a, '_animate')
        a.previousMonth()
        expect(a._animate).toHaveBeenCalledWith(pmp, pma, pmc, 'previousMonthFinished')

    describe "without custom animations", ->
      beforeEach ->
        a = new chronos.Animator(pm, {})

      it "calls animate with the defaults", ->
        spyOn(a, '_animate')
        spyOn(a, '_animatePreviousMonth')
        spyOn(a, '_animatePreviousMonthPrepare')
        spyOn(a, '_animatePreviousMonthCallback')
        a.previousMonth()
        expect(a._animate).toHaveBeenCalledWith(a._animatePreviousMonthPrepare,
          a._animatePreviousMonth, a._animatePreviousMonthCallback,
          'previousMonthFinished')


  describe "#nextMonth", ->
    describe "when given custom animations", ->
      nmp = jasmine.createSpy("nextMonthPrepare mock")
      nm = jasmine.createSpy("nextMonth mock")
      nmc = jasmine.createSpy("nextMonthCallback mock")
      beforeEach ->
        options =
          nextMonthPrepare: nmp
          nextMonth: nm
          nextMonthCallback: nmc
        a = new chronos.Animator(pm, options)

      it "calls animate with the correct arguments", ->
        spyOn(a, '_animate')
        a.nextMonth()
        expect(a._animate).toHaveBeenCalledWith(nmp, nm, nmc, 'nextMonthFinished')

    describe "without custom animations", ->
      beforeEach ->
        a = new chronos.Animator(pm, {})

      it "calls animate with the defaults", ->
        spyOn(a, '_animate')
        spyOn(a, '_animateNextMonth')
        spyOn(a, '_animateNextMonthPrepare')
        spyOn(a, '_animateNextMonthCallback')
        a.nextMonth()
        expect(a._animate).toHaveBeenCalledWith(a._animateNextMonthPrepare,
          a._animateNextMonth, a._animateNextMonthCallback,
          'nextMonthFinished')


  describe "private methods", ->

    describe "_animate", ->
      before = jasmine.createSpy("before mock")
      animation = jasmine.createSpy("animation mock")
      after = jasmine.createSpy("after mock")
      eventname = "eventName"
      beforeEach ->
        a.pickerManager = jasmine.createSpy("pickerManager mock")

      describe "when already animating", ->
        beforeEach ->
          a.animating = true
        for f in [before]
          it "does not call '#{f}'", ->
            a._animate(before, animation, after, eventname)
            expect(before).not.toHaveBeenCalled()

      describe "when not already animating", ->
        beforeEach ->
          a.animating = false
          a.$picker = jasmine.createSpy("picker mock")
          a.$picker.trigger = jasmine.createSpy('trigger mock')

        for f in [before, animation, after]
          it "does not call '#{f}'", ->
            a._animate(before, animation, after, eventname)
            expect(before).toHaveBeenCalled()

        it "triggers the 'eventName' event", ->
          a._animate(before, animation, after, eventname)
          expect(a.$picker.trigger).toHaveBeenCalledWith(eventname)


    describe "#_setElements", ->
      next = $("<div class='body_next' />")
      curr = $("<div class='body_curr' />")
      prev = $("<div class='body_prev' />")
      body = $("<div class='body' />")
      picker = $("<div />")
      body.append(next).append(curr).append(prev)
      picker.append(body)

      beforeEach ->
        a.$picker = picker

      it "sets @$body", ->
        a._setElements()
        expect(a.$body.hasClass('body')).toBeTruthy()

      it "sets @$next", ->
        a._setElements()
        expect(a.$next.hasClass('body_next')).toBeTruthy()

      it "sets @$curr", ->
        a._setElements()
        expect(a.$curr.hasClass('body_curr')).toBeTruthy()

      it "sets @$prev", ->
        a._setElements()
        expect(a.$prev.hasClass('body_prev')).toBeTruthy()


    # == NOT TESTING DEFAULT ANIMATIONS == #
