describe "Chronos", ->
  c = {}
  input = {}

  beforeEach ->
    c = new chronos.Chronos()
    input = "<input type='text' />"

  describe "public methods", ->

    describe "initialize", ->
      it "sets a mousedown event on the document so it knows when to close a picker", ->
        spyOn(c, '_externalClickClose')
        $(document).trigger('mousedown')
        expect(c._externalClickClose).toHaveBeenCalled()

    describe "#setCurrentElement", ->
      oldSettings = {}
      oldElement = {}
      newElement = {}
      newSettings = {}

      beforeEach ->
        oldSettings = {old: "settings"}
        oldElement = $(input)
        newElement = $(input)
        newSettings = {new: "settings"}
        $.data(newElement[0], chronos.Chronos.PROP_NAME, newSettings)
        spyOn(c, '_expirePicker')

      it "calls _expirePicker", ->
        c.setCurrentElement(newElement[0])
        expect(c._expirePicker).toHaveBeenCalled()

      it "sets the current settings for the given element", ->
        c.setCurrentElement(newElement[0])
        expect(c.current).toBe(newSettings)

    describe "#setDateRange", ->
      pending


  describe "private methods", ->

    describe "#_attach", ->
      beforeEach ->
        spyOn(c, '_saveCurrentSettings')

      it "sets @current.settings to the default settings if given no settings", ->
        c._attach(input, {})
        expect(c.current.options).toEqual(chronos.Chronos._defaultOptions)

      it "allows for overriding the default settings", ->
        c._attach(input, {valueFormat: 'X'})
        expect(c.current.options.valueFormat).toEqual('X')

      it "builds the displayElement", ->
        spyOn(c, '_buildDisplayElement').andReturn(["mockDisplayElement"])
        c._attach(input, {})
        expect(c._buildDisplayElement).toHaveBeenCalled()

      it "saves the valueElement to @current", ->
        c._attach(input, {})
        expect(c.current.valueElement).toBe(input)

      it "calls _saveCurrentSettings", ->
        c._attach(input, {})
        expect(c._saveCurrentSettings).toHaveBeenCalled()


    describe "_saveCurrentSettings", ->
      it "saves the settings using jquery's $.data", ->
        de = $("<div class='mock display element' />")
        c.current = {}
        c.current.displayElement = de[0]
        c.current.options = {some: 'settings'}
        c._saveCurrentSettings()
        expect($.data(de[0], chronos.Chronos.PROP_NAME)).toEqual(c.current)


    describe "#_buildDisplayElement", ->
      $ve = {}
      beforeEach ->
        $ve = $(input)
        c.current =
          options: chronos.Chronos._defaultOptions
          valueElement: $ve[0]

      it "returns the display element", ->
        expect(c._buildDisplayElement().hide()).not.toBeUndefined() #duck type

      it "removes the name attribute from the clone", ->
        $de = c._buildDisplayElement()
        expect($de.attr('name')).toBeUndefined()

      it "hides the valueElement if debug is disabled", ->
        $de = c._buildDisplayElement()
        expect($ve.attr('style')).toEqual('display: none; ')

      it "does not hide the value element if debug is enabled", ->
        c.current.options = $.extend(chronos.Chronos._defaultOptions, {debug: true})
        $de = c._buildDisplayElement()
        expect($ve.attr('style')).toBeUndefined()

      it "appends _display onto the id to avoid naming conflict", ->
        $de = c._buildDisplayElement()
        expect($de.attr('id')).toEqual($ve.attr('id') + "_display")

      describe "initial display value", ->
        it "sets the value if startBlank is false", ->
          $de = c._buildDisplayElement()
          expect($de.val()).toBeTruthy()

        it "sets the value if startBlank is false", ->
          c.current.options = $.extend(chronos.Chronos._defaultOptions, {startBlank: true})
          $de = c._buildDisplayElement()
          expect($de.val()).toBeFalsy()

      it "sets the current display elements so that it can be saved later", ->
        $de = c._buildDisplayElement()
        expect(c.current.displayElement).toBe($de[0])

      it "binds the 'focus' event", ->
        spyOn(c, '_onFocus')
        $de = c._buildDisplayElement()
        $de.trigger('focus')
        expect(c._onFocus).toHaveBeenCalled()

      it "binds the 'keyup' event", ->
        spyOn(c, '_onDisplayKeyUp')
        $de = c._buildDisplayElement()
        $de.trigger('keyup')
        expect(c._onDisplayKeyUp).toHaveBeenCalled()

      it "binds the 'keydown' event", ->
        spyOn(c, '_onDisplayKeyDown')
        $de = c._buildDisplayElement()
        $de.trigger('keydown')
        expect(c._onDisplayKeyDown).toHaveBeenCalled()


    describe "#_createPicker", ->
      beforeEach ->
        c.current =
          valueElement: $("<input />")
          options: chronos.Chronos._defaultOptions
          displayElement: $("<input />")

      it "creates a new picker", ->
        c.current.activePicker = undefined
        c._createPicker()
        expect(c.current.activePicker).not.toEqual(undefined)

      it "binds the picker's 'internal_close event", ->
        spyOn(c, '_onClose')
        c._createPicker()
        c.current.activePicker.$container.trigger('internal_close')
        expect(c._onClose).toHaveBeenCalled()

      it "returns the picker", ->
        expect(c._createPicker()).toBe(c.current.activePicker)


    describe "#_renderPicker", ->
      picker = newDefaultPicker()
      beforeEach ->
        c.current =
          valueElement: $(input)
          options: chronos.Chronos._defaultOptions
          displayElement: $("<div />")
        c.current.activePicker = picker

      it "creates the picker if there isn't one", ->
        c.current.activePicker = undefined
        spyOn(c, '_createPicker').andCallThrough()
        c._renderPicker()
        expect(c._createPicker).toHaveBeenCalled()

      it "renders the picker", ->
        spyOn(c, '_createPicker')
        spyOn(c.current.activePicker, 'render')
        c._renderPicker()
        expect(c.current.activePicker.render).toHaveBeenCalled()

      it "inserts the picker after the display element", ->
        spyOn(c, '_createPicker')
        spyOn(c.current.activePicker, 'insertAfter')
        c._renderPicker()
        expect(c.current.activePicker.insertAfter).toHaveBeenCalledWith($(c.current.displayElement))


    describe "#_findPickerFromEvent", ->
      picker = "<div class='chronos_picker' />"
      monthBody = "<div class='monthBody'></div>"
      day = "<div class='day'></div>"
      event = {}

      it "returns en empty jquery object if a picker was not found", ->
        event.target = "<div class='something else'></div>"
        test = c._findPickerFromEvent(event)
        expect(test.length).toEqual(0)

      it "can find a picker if target was a child", ->
        $picker = $(picker)
        $monthBody = $(monthBody)
        $day = $(day)
        $picker.append($monthBody.append($day))
        event.target = $day[0]
        test = c._findPickerFromEvent(event)
        expect(test.length).toEqual(1)

      it "can find a picker if target was a picker", ->
        event.target = picker
        test = c._findPickerFromEvent(event)
        expect(test.length).toEqual(1)


    describe "#_notActivePicker", ->
      $picker = {}

      describe "when given an invalid picker", ->
        it "returns true", ->
          $picker = jasmine.createSpy("picker")
          spyOn($picker, 'length').andReturn(0)
          expect(c._notActivePicker($picker)).toEqual(false)

      describe "when given a valid picker", ->
        beforeEach ->
          c.current =
            activePicker: {}

        it "returns true if the $picker element is not the activePicker element", ->
          $picker = $("<div>picker</div>")
          c.current.activePicker.$container = $("<div>not match</div>")
          expect(c._notActivePicker($picker)).toEqual(true)

        it "returns false if the $picker element is equal to the activePicker element", ->
          $picker = $("<div>picker</div>")
          c.current.activePicker.$container = $picker
          expect(c._notActivePicker($picker)).toEqual(false)


    describe "#_noPickerButActive", ->

      describe "when given a valid picker", ->
        it "returns false", ->
          $picker = $("<div>picker</div>")
          c.current = {}
          c.current.activePicker = "something"
          expect(c._noPickerButActive($picker)).toEqual(false)

      describe "when given an invalid picker", ->
        it "returns true if there is an active picker", ->
          $picker = jasmine.createSpy("mock picker")
          spyOn($picker, 'length').andReturn(0)
          c.current = {}
          c.current.activePicker = "something"
          expect(c._noPickerButActive($picker)).toEqual(true)

        it "returns false if the active picker is null", ->
          $picker = jasmine.createSpy("mock picker")
          spyOn($picker, 'length').andReturn(0)
          c.current = {}
          c.current.activePicker = null
          expect(c._noPickerButActive($picker)).toEqual(false)

        it "returns false if the active picker is undefined", ->
          $picker = jasmine.createSpy("mock picker")
          spyOn($picker, 'length').andReturn(0)
          c.current = {}
          c.current.activePicker = undefined
          expect(c._noPickerButActive($picker)).toEqual(false)


    describe "#_notActiveDisplay", ->

      it "returns false if there is no activePicker", ->
        c.current =
          activePicker: null
        expect(c._notActiveDisplay()).toEqual(true)

      it "returns true if there is an active picker but displayElement is not a match", ->
        event =
          target: "not a match"
        $target = $("<div class='target'>")
        c.current =
          activePicker:
            $displayElement: $target
        expect(c._notActiveDisplay(event)).toEqual(true)

      it "returns false if there is an active picker and its displayElement matches", ->
        $target = $("<div class='target'>")
        event =
          target: $target[0]
        c.current =
          activePicker:
            $displayElement: $target
        expect(c._notActiveDisplay(event)).toEqual(false)


    describe "#_externalClickClose", ->

      it "does not call #_directClose if there are not current settings", ->
        c.current = null
        spyOn(c, '_directClose')
        c._externalClickClose()
        expect(c._directClose).not.toHaveBeenCalled()

      describe "when there are current settings", ->
        beforeEach ->
          c.current = {}
          spyOn(c, '_findPickerFromEvent')
          spyOn(c, '_directClose')

        it "does not call #_directClose if it is the active displayElement", ->
          c.current = {}
          spyOn(c, '_notActiveDisplay').andReturn(false)
          c._externalClickClose()
          expect(c._directClose).not.toHaveBeenCalled()

        describe "when given a picker", ->
          beforeEach ->
            spyOn(c, '_noPickerButActive')

          it "calls #_directClose if it is not the active one", ->
            spyOn(c, '_notActivePicker').andReturn(true)
            c._externalClickClose()
            expect(c._directClose).toHaveBeenCalled()

          it "does not call #_directClose if it is the active one", ->
            spyOn(c, '_notActivePicker').andReturn(false)
            c._externalClickClose()
            expect(c._directClose).not.toHaveBeenCalled()

        describe "when no picker is found", ->
          beforeEach ->
            spyOn(c, '_notActivePicker')

          it "calls #_directClose if it is the active one", ->
            spyOn(c, '_noPickerButActive').andReturn(true)
            c._externalClickClose()
            expect(c._directClose).toHaveBeenCalled()

          it "does not call #_directClose if there is no active picker", ->
            spyOn(c, '_noPickerButActive').andReturn(false)
            c._externalClickClose()
            expect(c._directClose).not.toHaveBeenCalled()


    describe "#_expirePicker", ->
      activePicker = "mockActivePicker"
      beforeEach ->
        c.current = {}

      describe "when there is an active picker", ->

        it "adds the active picker to the array of expiredPickers", ->
          c.current.activePicker = activePicker
          c._expirePicker()
          expect(c.expiredPickers[0]).toEqual(activePicker)

      describe "when there is not an active picker", ->

        it "does not add the active picker to the expiredPickers array", ->
          c.current.activePicker = null
          c._expirePicker()
          expect(c.expiredPickers.length).toEqual(0)

      it "sets the activePicker to null", ->
        c.current.activePicker = activePicker
        c._expirePicker()
        expect(c.activePicker).toBeNull()


    describe "#_directClose", ->
      beforeEach ->
        spyOn(c, '_expirePicker')
        spyOn(c, '_closePickers')
        c._directClose()

      it "calls #_expirePicker", ->
        expect(c._expirePicker).toHaveBeenCalled()

      it "calls #_closePickers", ->
        expect(c._closePickers).toHaveBeenCalled()


    describe "#_closePickers", ->

      describe "when there are no expiredPickers", ->
        it "does not attempt to close any", ->
          c.expiredPickers = []
          spyOn(c.expiredPickers, 'pop')
          c._closePickers()
          expect(c.expiredPickers.pop).not.toHaveBeenCalled()

      describe "when there are expiredPickers", ->
        mock_picker = {close: "whatever"}
        beforeEach ->
          c.expiredPickers = [mock_picker]
          spyOn(mock_picker, 'close')
          c._closePickers()

        it "pops pickers from the list", ->
          expect(c.expiredPickers.length).toEqual(0)

        it "closes the picker", ->
          expect(mock_picker.close).toHaveBeenCalled()


    describe "#_isCurrentPicker", ->
      beforeEach ->
        c.current = {}

      it "returns false if the active picker is undefined", ->
        c.current.activePicker = undefined
        expect(c._isCurrentPicker()).toEqual(false)

      it "returns false if the active picker is null", ->
        c.current.activePicker = null
        expect(c._isCurrentPicker()).toEqual(false)

      describe "when there is an active picker", ->

        it "returns true if the picker's display element is equal to the target", ->
          target = "some element"
          c.current.activePicker =
            $displayElement: [target]
          expect(c._isCurrentPicker(target)).toEqual(true)

        it "returns false if the picker's display element is not equal to the target", ->
          target = "some element"
          c.current.activePicker =
            $displayElement: ["some other display element"]
          expect(c._isCurrentPicker(target)).toEqual(false)


  describe "events", ->

    describe "#_onFocus", ->
      beforeEach ->
        c.current =
          activePicker: undefined
        spyOn(c, 'setCurrentElement')
        spyOn(c, '_renderPicker')

      describe "when not the activePicker", ->
        beforeEach ->
          spyOn(c, "_isCurrentPicker").andReturn(false)

        it "calls #setCurrentElement", ->
          c._onFocus({target: "some target"})
          expect(c.setCurrentElement).toHaveBeenCalledWith("some target")

        it "calls #_renderPicker", ->
          c._onFocus({target: "some target"})
          expect(c._renderPicker).toHaveBeenCalled()

      describe "when it is the active picker", ->
        beforeEach ->
          spyOn(c, "_isCurrentPicker").andReturn(true)

        it "does not call #setCurrentElement", ->
          c._onFocus({target: "some target"})
          expect(c.setCurrentElement).not.toHaveBeenCalled()

        it "does not call #_renderPicker", ->
          c._onFocus({target: "some target"})
          expect(c._renderPicker).not.toHaveBeenCalled()

    describe "#_onClose", ->
      mock_event = {stopPropagation: "whatever"}
      beforeEach ->
        spyOn(mock_event, 'stopPropagation')
        spyOn(c, '_directClose')

      it "stops event propagation", ->
        c._onClose(mock_event)
        expect(mock_event.stopPropagation).toHaveBeenCalled()

      it "calls #_directClose", ->
        c._onClose(mock_event)
        expect(c._directClose).toHaveBeenCalled()

    describe "#_onDisplayKeyUp", ->
      beforeEach ->
        c.current =
          activePicker:
            checkAndSetDate: jasmine.createSpy('picker')

      it "calls #checkAndSetDate on the picker", ->
        c._onDisplayKeyUp()
        expect(c.current.activePicker.checkAndSetDate).toHaveBeenCalled()


    describe "#_onDisplayKeyDown", ->
      event = {}
      keys = {}
      v = ""

      beforeEach ->
        c.current =
          activePicker:
            $displayElement: $("<div />")
        spyOn(c, '_directClose')
        spyOn(c.current.activePicker.$displayElement, 'blur')

      it "calls #_directClose when the 'ENTER' key is pressed", ->
        event.keyCode = 13
        c._onDisplayKeyDown(event)
        expect(c._directClose).toHaveBeenCalled()

      it "calls #_directClose when the 'TAB' key is pressed", ->
        event.keyCode = 9
        c._onDisplayKeyDown(event)
        expect(c._directClose).toHaveBeenCalled()

      it "calls #_directClose when the 'ESCAPE' key is pressed", ->
        event.keyCode = 27
        c._onDisplayKeyDown(event)
        expect(c._directClose).toHaveBeenCalled()

      it "blurs the displayElement when the 'ENTER' key is pressed", ->
        event.keyCode = 13
        c._onDisplayKeyDown(event)
        expect(c.current.activePicker.$displayElement.blur).toHaveBeenCalled()

      it "blurs the displayElement when the 'ESCAPE' key is pressed", ->
        event.keyCode = 27
        c._onDisplayKeyDown(event)
        expect(c.current.activePicker.$displayElement.blur).toHaveBeenCalled()

      it "does not blur the displayElement when the 'TAB' key is pressed
          because that screws with the picker display", ->
        event.keyCode = 9
        c._onDisplayKeyDown(event)
        expect(c.current.activePicker.$displayElement.blur).not.toHaveBeenCalled()