class chronos.Picker

  constructor: (current) ->
    @current = current
    @_initialize()

  build: ->
    picker = @_createContainer()

  _initialize: ->

    console.log "HERE"

  # returns container div for picker
  _createContainer: ->
    console.log "Current is", @current
    klass = "chronos_picker"
    klass += " #{@current.options.pickerClass}" if @current.options.pickerClass

    $("<div class='#{klass}' />")




