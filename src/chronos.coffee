# This Class is responsible for managing the various datepickers that may be instantiated.
class chronos.Chronos

  constructor: () ->
    @current = null
    @activePicker = null
    @expiredPickers = [] # array of picker elements
    @initialize()

  @PROP_NAME: 'chronos_element_settings'

  @_defaultOptions:
    pickerClass: ''

    # Note that order in the following arrays is important for date formatting.
    # Use startDay option to offset the week's starting day for display in calendar.
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
    startBlank: false # allow the datepicker to start empty / blank
    displayFormat: 'isoDate' # format to display after making selection through picker
    typedInputFormat: 'isoDate' # format to allow user to manually type in value
    valueFormat: 'U' # format to post to the server
    yearsPerPage: 20
    maxDate: undefined
    minDate: undefined
    startDay: 0  # Sunday (0) through Saturday (6) - be aware that this may affect your
                 # layout, since the days on the right might have a different margin
    pickedDateTime: undefined # start datepicker at a specific date
    useTimePicker: false # set to true to be able to set time with date
    timePickerOnly: false # only use a time picker
    yearOnly: false # only use yearly selection
    animations: {}
    positionOffset: {top: 0, left: 0} # offset to adjust position of picker
    debug: false

  @events: ['opened', 'closed', 'daySelected', 'previousMonthFinished',
            'nextMonthFinished', 'invalidDate', 'validDate']


  ###
    PUBLIC METHODS
  ###

  initialize: ->
    # close datepicker if clicked anywhere in document except current picker
    $(document).mousedown (event) =>
      @_externalClickClose(event)

  # Set the manager's current settings to the given element
  # Pushes the current settings to the oldList to be dealt with later, i.e. closing
  # Requires an htmlElement
  setCurrentElement: (element) ->
    @_expirePicker()
    @current = $.data(element, chronos.Chronos.PROP_NAME)

  # limit picker's date range
  # accepts a range object in the form:
  #   range:
  #     minDate: Date()
  #     maxDate: Date()
  setDateRange: (range) ->
    if @current.activePicker
      @current.activePicker.setDateRange(range)
    else
      @current.options.minDate = range.minDate
      @current.options.maxDate = range.maxDate
      @_saveCurrentSettings()



  ###
    Private methods
  ###

  _saveCurrentSettings: ->
    # store element specific instance properties, but must use the display_element
    # as that is the element which triggers onfocus
    $.data(@current.displayElement, chronos.Chronos.PROP_NAME, @current);

  # Attach the chronos datepicker to the given input
  # Returns chronos object
  # This function effectively initializes a datepicker and saves its settings
  _attach: (element, options) ->
    @current =
      options: $.extend({}, chronos.Chronos._defaultOptions, options);
      valueElement: element

    $de = @_buildDisplayElement()
    @current.displayElement = $de[0]
    @_saveCurrentSettings()
    @

  # creates a duplicate input element for display purposes
  # Returns the display element
  _buildDisplayElement: ->
    s = @current.options
    df = new chronos.DateFormatter(s)
    $ve = $(@current.valueElement)
    initValue = $ve.val()

    # Set initial display value
    initValue = if initValue
      df.format(initValue, s.displayFormat)
    else
      if s.startBlank then "" else df.format(new Date(), s.displayFormat)

    displayClass = "chronos_picker_display"
    displayClass += " #{@current.options.pickerClass}_display" if @current.options.pickerClass
    $displayElement = $ve.clone(true) # make copy of input element
      .removeAttr('name') # remove name attribute so value is not posted to server
      .attr('id', $ve.attr('id') + '_display') # avoid id conflict
      .addClass(displayClass)
      .val(initValue) # set initial display value to initial valueElement value

    # show valueElement during debug mode
    unless s.debug
      $ve.hide()

    $displayElement.bind
      'focus':  (event) =>
        @_onFocus(event)
      'keyup': (event) =>
        @_onDisplayKeyUp(event)
      'keydown': (event) =>
        @_onDisplayKeyDown(event)

    $ve.before($displayElement) # place clone before valueElement

    @current.displayElement = $displayElement[0]

    $displayElement

  # Construct a date picker and render it
  _renderPicker: ->
    @_createPicker() unless @current.activePicker
    @current.activePicker.render()
    @current.activePicker.insertAfter($(@current.displayElement))
    @current.activePicker

  # Create a new picker.
  _createPicker: ->
    picker = new chronos.Picker(@current)
    @current.activePicker = picker
    # To handle events originating in picker which would result in the removal
    # of the picker itself.
    picker.$container.on
      'internal_close': (event) =>
        @_onClose(event)
    picker

  # place the settings into the expiredPickers array
  _expirePicker: ->
    @expiredPickers.push @current.activePicker if @current.activePicker
    @current.activePicker = null

  # iterate through the expiredPickers array and close each associated picker
  # if it exists
  _closePickers: ->
    while @expiredPickers.length > 0
      picker = @expiredPickers.pop()
      picker.close()

  # close current picker directly, i.e. not through a different onFocus event
  _directClose: ->
    @_expirePicker()
    @_closePickers()

  # Attempt to find a picker given a Jquery Event object
  _findPickerFromEvent: (event) ->
    $target = $(event.target)
    $picker = if $target.hasClass('chronos_picker')
      $target
    else
      $target.parents('.chronos_picker')

  # Returns true if given picker is valid and not the active Picker
  _notActivePicker: ($picker, event) ->
    $picker.length > 0 && $picker[0] != @current.activePicker.$container[0]

  # Return true if given picker is invalid and we have an active picker
  _noPickerButActive: ($picker) ->
    $picker.length <= 0 && (@current.activePicker != null && @current.activePicker != undefined)

  _notActiveDisplay: (event) ->
    if @current.activePicker
      @current.activePicker.$displayElement[0] != event.target
    else
      true

  # Close datepicker if clicked anywhere in document except current picker or
  # current displayElement
  _externalClickClose: (event) ->
    if @current
      $picker = @_findPickerFromEvent(event)

      # Close picker if we're clicking on a different picker somehow
      # or if we're clicking elsewhere and there's an active picker
      # Do not close if we're clicking on the currently active picker or displayElement
      if @_notActiveDisplay(event) && (@_notActivePicker($picker, event) ||
      @_noPickerButActive($picker))
        @_directClose()

  # returns true if given element is associated with the activePicker
  _isCurrentPicker: (target) ->
    @current.activePicker != undefined &&
    @current.activePicker != null &&
    @current.activePicker.$displayElement[0] == target


  ###
    EVENT HANDLERS
  ###

  # Used for focus on displayElement
  # Before starting anything, set the current element to obtain the correct picker
  # and its associated settings.  Then render the picker unless it's the current picker.
  _onFocus: (event) ->
    unless @_isCurrentPicker(event.target)
      @setCurrentElement(event.target)
      @_renderPicker()


  # This method is called when a picker triggers 'internal_close' to tell chronos
  # to proceed with removing the element
  _onClose: (event) ->
    event.stopPropagation() # do not propagate 'internal_close' event
    @_directClose()


  # This event allows a user to type into the display element instead of using
  # the date picker or for accessibility control features
  _onDisplayKeyUp: (event) ->
    # TODO: Accessibility
    if @current.activePicker
      @current.activePicker.checkAndSetDate()


  # handle keydown on displayElement
  _onDisplayKeyDown: (event) ->
    # blur if ENTER OR ESC
    if event.keyCode == 13 || event.keyCode == 27
      @current.activePicker.$displayElement.blur()
    # close on ENTER, TAB, or ESC key
    if event.keyCode == 13 || event.keyCode == 9 || event.keyCode == 27
      @_directClose()








