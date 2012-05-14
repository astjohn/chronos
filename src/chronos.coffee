# This Class is responsible for managing the various datepickers that may be instantiated.
class chronos.Chronos

  constructor: () ->
    @current = {}
    @activePicker = {}
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
    useTimePicker: false # set to true to be able to set time with date
    animations: {}
    debug: false

  @events: ['daySelect', 'previousMonthFinished', 'nextMonthFinished']


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

    $displayElement = $ve.clone(true) # make copy of input element
      .removeAttr('name') # remove name attribute so value is not posted to server
      .attr('id', $ve.attr('id') + '_display') # avoid id conflict
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
    @activePicker = new chronos.Picker(@current)
    #p.build()

    @activePicker.$container.on
      'close': (event) =>
        @_onClose(event)


    # TODO: TEMPORARY
    @activePicker._renderMonths()

    $(@current.displayElement).after(@activePicker.$container)

    @current.activePicker = @activePicker.$container[0]

    @activePicker


  # place the settings into the expiredPickers array
  _expirePicker: ->
    @expiredPickers.push @current if @current

  # iterate through the expiredPickers array and close each associated picker
  # if it exists
  _closePickers: ->

    # TODO: use when/then to animate closing ???
    while @expiredPickers.length > 0
      settings = @expiredPickers.pop()
      $pickerElement = $(settings.activePicker)
      if $pickerElement.length > 0
        $pickerElement.remove()


  # close current picker directly, i.e. not through a different onFocus event
  _directClose: ->
    @_expirePicker()
    @_closePickers()


  # Close datepick if clicked anywhere in document except current picker or
  # current displayElement
  _externalClickClose: (event) ->
    $target = $(event.target)
    $picker = if $target.hasClass('.chronos_picker') then $target else $target.parents('.chronos_picker')
    unless ($picker.length > 0 && $picker[0] == @current.activePicker) || event.target == @current.displayElement
      @_directClose()


  ###
    EVENT HANDLERS
  ###

  # Used for focus on displayElement
  # Before starting anything, set the current element to obtain the correct picker
  # and its associated settings.  Then render the picker.
  _onFocus: (event) ->
    @setCurrentElement(event.target)
    @_renderPicker()


  # This method is called from within a picker to directly close itself
  _onClose: (event) ->
    event.stopPropagation()
    console.log "CHRONOS CLOSE!", @, event
    @_directClose()






