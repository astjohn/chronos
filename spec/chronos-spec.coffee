describe "chronos", ->
  c = new Chronos()
  input = "<input type='text' />"

  describe "public methods", ->

    describe "#setCurrentElement", ->
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

      #it "persists the given element's settings using $.data"