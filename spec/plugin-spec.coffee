describe "Plugin Setup", ->
  $element = {}

  beforeEach ->
    $element = $("<input type='text' />")
    $element.chronos()


  describe "creating a chronos enabled element", ->

    it "should create a chronos object", ->
      expect($element.chronos()).toBeDefined()

    it "should be a chainable object", ->
      $element.chronos().addClass('chainable')
      expect($element.hasClass('chainable')).toBeTruthy()

    it "should set that the element has been chronofied", ->
      expect($.data($element[0], "chronos")).toBeTruthy()

    it "should call the _attach method with the given
        options to initialize the datepicker", ->
      $el = $("<input type='text' />")
      $.chronos._attach = jasmine.createSpy("_attach")
      $el.chronos({some: "options"})
      expect($.chronos._attach).toHaveBeenCalledWith($el[0], {some: "options"})

    it "should call the _attach method with empty options if none were given", ->
      $el = $("<input type='text' />")
      $.chronos._attach = jasmine.createSpy("_attach")
      $el.chronos()
      expect($.chronos._attach).toHaveBeenCalledWith($el[0], {})

    it "should not call the _attach method if element already
        has a datepicker associated", ->
      $el = $("<input type='text' />")
      $el.chronos()
      $.chronos._attach = jasmine.createSpy("_attach")
      $el.chronos({some: "options"})
      expect($.chronos._attach).not.toHaveBeenCalled()


  describe "for indirect access to public methods", ->
    publicMethod = "setDateRange"

    it "should give an error if given an unknown command", ->
      c = console
      c.error = jasmine.createSpy("console warning spy")
      $element.chronos("someUnknown", {})
      expect(c.error).toHaveBeenCalledWith('chronos: Unknown command: someUnknown')

    it "should give a warning if given an element that has not been chronofied", ->
      $otherElement = $("<input type='text' />")
      c = console
      c.warn = jasmine.createSpy("console warning spy")
      $otherElement.chronos(publicMethod, {})
      expect(c.warn).toHaveBeenCalledWith('chronos: Unknown datepicker.')

    it "should first set the current element", ->
      plugin = $.chronos
      plugin.setCurrentElement = jasmine.createSpy("setCurrentElement")
      $element.chronos(publicMethod, {})
      expect(plugin.setCurrentElement).toHaveBeenCalledWith($element[0])


    it "should call the method within the chronos class", ->
      plugin = $.chronos
      plugin[publicMethod] = jasmine.createSpy("setDateRange")
      $element.chronos(publicMethod, {})
      expect(plugin[publicMethod]).toHaveBeenCalledWith({})

  describe "gives direct access to public methods", ->
    plugin = $.chronos

    describe "#setDateRange", ->
      method = "setDateRange"
      it "should first set the current element", ->
        plugin.setCurrentElement = jasmine.createSpy("setCurrentElement")
        $element.chronos(method, {})
        expect(plugin.setCurrentElement).toHaveBeenCalledWith($element[0])

      it "should call the setDateRange", ->
        plugin[method] = jasmine.createSpy("setDateRange")
        $element.setDateRange({okie: "dokie"})
        expect(plugin.setDateRange).toHaveBeenCalledWith({okie: "dokie"})
