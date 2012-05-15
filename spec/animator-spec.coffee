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
      animation = jasmine.createSpy("custom animation mock")
      beforeEach ->
        options =
          previousMonth: animation
        a = new chronos.Animator(pm, options)

      it "calls animate with the correct arguments", ->
        spyOn(a, '_animate')
        a.previousMonth()
        expect(a._animate).toHaveBeenCalledWith(animation, 'previousMonthFinished')

    describe "without custom animations", ->
      beforeEach ->
        a = new chronos.Animator(pm, {})

      it "calls animate with the defaults", ->
        spyOn(a, '_animate')
        spyOn(a, '_animatePreviousMonth')
        a.previousMonth()
        expect(a._animate).toHaveBeenCalledWith(a._animatePreviousMonth,
          'previousMonthFinished')


  describe "#nextMonth", ->
    describe "when given custom animations", ->
      animation = jasmine.createSpy('custom animation mock')
      beforeEach ->
        options =
          nextMonth: animation
        a = new chronos.Animator(pm, options)

      it "calls animate with the correct arguments", ->
        spyOn(a, '_animate')
        a.nextMonth()
        expect(a._animate).toHaveBeenCalledWith(animation, 'nextMonthFinished')

    describe "without custom animations", ->
      beforeEach ->
        a = new chronos.Animator(pm, {})

      it "calls animate with the defaults", ->
        spyOn(a, '_animate')
        spyOn(a, '_animateNextMonth')
        a.nextMonth()
        expect(a._animate).toHaveBeenCalledWith(a._animateNextMonth,
          'nextMonthFinished')

  describe "#close", ->
    describe "when given custom animations", ->
      animation = jasmine.createSpy('custom animation mock')
      beforeEach ->
        options =
          close: animation
        a = new chronos.Animator(pm, options)

      it "calls animate with the correct arguments", ->
        spyOn(a, '_animate')
        a.close()
        expect(a._animate).toHaveBeenCalledWith(animation, 'close')

    describe "without custom animations", ->
      beforeEach ->
        a = new chronos.Animator(pm, {})

      it "calls animate with the defaults", ->
        spyOn(a, '_animate')
        spyOn(a, '_animateClose')
        a.close()
        expect(a._animate).toHaveBeenCalledWith(a._animateClose, 'close')


  describe "private methods", ->

    describe "_animate", ->
      animation = jasmine.createSpy("animation mock")
      eventname = "eventName"
      beforeEach ->
        a.pickerManager = jasmine.createSpy("pickerManager mock")

      describe "when already animating", ->
        beforeEach ->
          a.animating = true
          it "does not call the animation", ->
            a._animate(animation, eventname)
            expect(animation).not.toHaveBeenCalled()

      describe "when not already animating", ->
        beforeEach ->
          a.animating = false
          a.$picker = jasmine.createSpy("picker mock")

        it "sets @animating to true", ->
          a._animate(animation, eventname)
          expect(a.animating).toBe(true)

        it "sets @currentEventName to the given event name so we can trigger it later", ->
          a._animate(animation, eventname)
          expect(a.currentEventName).toBe(eventname)

        describe "if animation is a function", ->
          it "calls the animation", ->
            spyOn(animation, 'apply')
            a._animate(animation, eventname)
            expect(animation.apply).toHaveBeenCalledWith(a, [a.pickerManager])

        describe "if animation is not a function", ->
          it "does not call the animation", ->
            spyOn(animation, 'apply')
            a._animate("not a function", eventname)
            expect(animation.apply).not.toHaveBeenCalled()


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
