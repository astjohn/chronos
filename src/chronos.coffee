# This Class is responsible for managing the various datepickers that may be instantiated.
class chronos.Chronos

  constructor: () ->
    @current = {}
    @pickers = []
    @oldList = []
    @PROP_NAME = 'chronos_element_settings'



  _defaultOptions:
    pickerClass: 'wpd'

    dayNames: [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sunday",
                "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]
    dayNamesAbbr: [ "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    monthNames: [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct",
                  "Nov", "Dec", "January", "February", "March", "April", "May", "June",
                  "July", "August", "September", "October", "November", "December" ]
    amLower: 'am'
    amUpper: 'AM'
    amAbbrLower: 'a'
    amAbbrUpper: 'A'
    pmLower: 'pm'
    pmUpper: 'PM'
    pmAbbrLower: 'p'
    pmAbbrUpper: 'P'
    startBlank: false
    displayFormat: 'default'
    timePicker: true
    valueFormat: 'U'
    debug: false


  ###
    PUBLIC METHODS
  ###

  # Set the manager's current settings to the given element
  # Pushes the current settings to the oldList to be dealt with later, i.e. closing
  # Requires an htmlElement
  setCurrentElement: (element) ->
    @oldList.push @current if @current
    @current = $.data(element, @PROP_NAME)

  setDateRange: (range) ->
    #console.log "WORKS"


  ###
    Private methods
  ###

  # Attach the chronos datepicker to the given input
  # Returns chronos object
  _attach: (element, options) ->
    @current =
      settings: $.extend({}, this._defaultOptions, options);
      valueElement: element

    $de = @_buildDisplayElement()
    @current.displayElement = $de[0]
    @

  # creates a duplicate input element for display purposes
  # Returns the display element
  _buildDisplayElement: ->
    s = @current.settings
    df = new chronos.DateFormatter(s)
    $ve = $(@current.valueElement)
    initValue = $ve.val()

    # Set initial display value
    initValue = if initValue
      df.format(initValue, s.displayFormat)
    else
      if s.startBlank then "" else df.format(new Date(), s.displayFormat)

    $displayElement = $ve.clone(true) # make copy of input element
      .removeAttr('name') # remove name attribute so value is not posted to server
      .attr('id', $ve.attr('id') + '_display') # avoid id conflict
      .val(initValue) # set initial value

    # show valueElement during debug mode
    unless s.debug
      $ve.hide()

    $displayElement.bind
      'focus':  (event) =>
        @_onFocus(event)

      'blur': (event) =>
        @_onBlur(event)

    $ve.before($displayElement) # place clone before valueElement

    # store element specific instance properties, but must use the display_element
    # as that is the element which triggers onfocus
    $.data($displayElement[0], @PROP_NAME, @current);

    $displayElement

  # Construct a date picker and render it
  _renderPicker: ->
    p = new chronos.Picker(@current)




  ###
    BINDINGS
  ###

  # Used for focus on displayElement
  _onFocus: (event) ->
    @setCurrentElement(event.target)
    @_renderPicker()

  # Used for blur on displayElement
  _onBlur: (event) ->
    console.log "Blur!", @
    # TODO: close picker, destroy stuff
