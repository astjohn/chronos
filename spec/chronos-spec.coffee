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
        $(input).mousedown()
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

      it "calls _expirePicker", ->
        spyOn(c, '_expirePicker')
        c.setCurrentElement(newElement[0])
        expect(c._expirePicker).toHaveBeenCalled()

      it "sets the current settings for the given element", ->
        c.setCurrentElement(newElement[0])
        expect(c.current).toBe(newSettings)


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


    describe "#_renderPicker", ->
      pending


  describe "events", ->

    describe "#_onFocus", ->

      it "calls #setCurrentElement", ->
        spyOn(c, '_renderPicker').andReturn("mock")
        c.setCurrentElement = jasmine.createSpy("setCurrentElement")
        c._onFocus({target: "some target"})
        expect(c.setCurrentElement).toHaveBeenCalledWith("some target")

      it "calls #_renderPicker", ->
        c._renderPicker = jasmine.createSpy("_renderPicker")
        c._onFocus({target: "some target"})
        expect(c._renderPicker).toHaveBeenCalled()
