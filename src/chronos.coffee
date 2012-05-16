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
    valueFormat: 'U' # number of millisecond since midnight January 1, 1970
    yearsPerPage: 20
    maxDate: null
    minDate: null
    startDay: 0  # Sunday (0) through Saturday (6) - be aware that this may affect your
                 # layout, since the days on the right might have a different margin
    pickedDateTime: null # start datepicker at a specific date
    useTimePicker: false # set to true to be able to set time with date
    animations: {}
    debug: false

  @events: ['opened', 'closed', 'daySelected', 'previousMonthFinished',
            'nextMonthFinished']


  ###
    PUBLIC METHODS
  ###

  initialize: ->
    # TODO: close on TAB key
    # close datepicker if clicked anywhere in document except current picker
    $(document).mousedown (event) =>
      @_externalClickClose(event)

  # Set the manager's current settings to the given element
  # Pushes the current settings to the oldList to be dealt with later, i.e. closing
  # Requires an htmlElement
  setCurrentElement: (element) ->
    @_expirePicker()
    @current = $.data(element, chronos.Chronos.PROP_NAME)

  setDateRange: (range) ->
    #console.log "WORKS"



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

    $ve.before($displayElement) # place clone before valueElement

    @current.displayElement = $displayElement[0]

    $displayElement

  # Construct a date picker and render it
  _renderPicker: ->
    activePicker = unless @current.activePicker
      @_createPicker()
    else
      @current.activePicker


    # TODO: TEMPORARY
    activePicker._renderMonths()
    activePicker.insertAfter($(@current.displayElement))

    @current.activePicker = activePicker
    activePicker

  # Create a new picker.
  _createPicker: ->
    picker = new chronos.Picker(@current)
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
  _notActivePicker: ($picker) ->
    $picker.length > 0 && $picker[0] != @current.activePicker.$container[0]

  # Return true if given picker is invalid and we have an active picker
  _noPickerButActive: ($picker) ->
    $picker.length <= 0 && (@current.activePicker != null && @current.activePicker != undefined)

  # Close datepicker if clicked anywhere in document except current picker or
  # current displayElement
  _externalClickClose: (event) ->
    if @current
      $picker = @_findPickerFromEvent(event)

      # Close picker if we're clicking on a different picker somehow
      # or if we're clicking elsewhere and there's an active picker
      # Do not close if we're clicking on the currently active picker
      @_directClose() if @_notActivePicker($picker) || @_noPickerButActive($picker)

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






