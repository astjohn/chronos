describe "picker", ->
  input = "<input type='text' />"


  describe "creating a new picker", ->

    it "sets it's $valueElement to a jQuery object", ->
      p = new Picker(input)
      expect(p.$valueElement.hide()).not.toBeUndefined() # duck type
