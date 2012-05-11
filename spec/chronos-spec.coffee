describe "chronos", ->
  c = {}
  input = {}

  beforeEach ->
    c = new chronos.Chronos()
    input = "<input type='text' />"

  describe "public methods", ->

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
        $.data(newElement[0], c.PROP_NAME, newSettings)

      it "pushes the current settings to the old list", ->
        c.current = oldSettings
        c.setCurrentElement(oldElement[0])
        expect(c.oldList[0]).toBe(oldSettings)

      it "sets the current settings for the given element", ->
        c.setCurrentElement(newElement[0])
        expect(c.current).toBe(newSettings)


  describe "private methods", ->

    describe "#_attach", ->

      it "sets @current.settings to the default settings if given no settings", ->
        c._attach(input, {})
        expect(c.current.settings).toEqual(c._defaultOptions)

      it "allows for overriding the default settings", ->
        c._attach(input, {valueFormat: 'X'})
        expect(c.current.settings.valueFormat).toEqual('X')

      it "builds the displayElement", ->
        spyOn(c, '_buildDisplayElement').andReturn(["mockDisplayElement"])
        c._attach(input, {})
        expect(c._buildDisplayElement).toHaveBeenCalled()

      it "saves the valueElement to @current", ->
        c._attach(input, {})
        expect(c.current.valueElement).toBe(input)

      it "saves the displayElement to @current", ->
        spyOn(c, '_buildDisplayElement').andReturn(["mockDisplayElement"])
        c._attach(input, {})
        expect(c.current.displayElement).toEqual("mockDisplayElement")


    describe "#_buildDisplayElement", ->
      $ve = {}
      beforeEach ->
        $ve = $(input)
        c.current =
          settings: c._defaultOptions
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
        c.current.settings = $.extend(c._defaultOptions, {debug: true})
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
          c.current.settings = $.extend(c._defaultOptions, {startBlank: true})
          $de = c._buildDisplayElement()
          expect($de.val()).toBeFalsy()

      it "persists the given element's settings using $.data and the display element", ->
        $de = c._buildDisplayElement()
        expect($.data($de[0], c.PROP_NAME)).toBeTruthy()


    describe "#_renderPicker", ->
      it "creates a new Picker", ->
        spyOn(chronos, 'Picker')
        c._renderPicker()
        expect(chronos.Picker).toHaveBeenCalledWith(c.current)


  describe "bindings", ->

    describe "#_onFocus", ->

      it "calls #setCurrentElement", ->
        c.setCurrentElement = jasmine.createSpy("setCurrentElement")
        c._onFocus({target: "some target"})
        expect(c.setCurrentElement).toHaveBeenCalledWith("some target")

      it "calls #_renderPicker", ->
        c._renderPicker = jasmine.createSpy("_renderPicker")
        c._onFocus({target: "some target"})
        expect(c._renderPicker).toHaveBeenCalled()
