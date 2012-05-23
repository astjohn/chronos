class chronos.Picker

  constructor: (current) ->
    @current = current # to reference and save picker's options
    @$container = undefined # to hold the picker
    @startingDate = undefined # the start date to show
    @mode = undefined # the mode to render, i.e. months, years, time, etc.
    @todayDate = new Date() # for today
    @current.pickedDateTime ||= current.options.pickedDateTime
    @$valueElement = $(current.valueElement)
    @$displayElement = $(current.displayElement)
    @dateFormatter = new chronos.DateFormatter(current.options)
    @animator = undefined

    @_initialize()





  ###
    Public Methods
  ###

  # render according to @mode value
  render: ->
    @_emptyBody()
    switch @mode
      when 'year'
        @_renderYears()
      when 'time'
        @_renderTime()
      else
        @_renderMonths()

  # This method animated the close event and then triggers the removal of the picker
  # from the DOM.
  # Chronos listens for close events to manage removal of all pickers.
  # Chronos will call close on picker when necessary
  close: ->
    unless @closing
      @closing = true
      @animator.close()

  # Insert picker into DOM after container element and animate
  insertAfter: ($element) ->
    $element.after(@$container)
    @setPosition()
    @animator.open()

  # set the picker's position according to screen real estate or given
  # position object expected to be in the form accepted by css method
  setPosition: (position) ->
    position = position || @_getPosition()
    @$container.css(position).css(position: "absolute")

  # set the display and value element's date and save settings
  setDate: (date) ->
    if $.isFunction(date.getMonth) # check valid date
      @_saveDate(date)
      @_updateInputValues()

  # This method will check for a valid date within the displayElement after a keypress
  # handled within Chronos' _onDisplayKeyPress.
  # If the date is valid, it will set the valueElement's value and trigger the
  # 'validDate' event.  Otherwise, it will trigger the 'invalidDate' event.
  checkAndSetDate: ->
    date = @dateFormatter.unformat(@$displayElement.val(), @current.options.displayFormat)
    unless date == false
      @_saveDate(date)
      @_updateValueElement()
      @$container.trigger('validDate')
      @render() # re-render picker to instantly show chosen value
    else
      @$container.trigger('invalidDate')

  setDateRange: (range) ->
    if range.minDate
      if @_isValidDate(range.minDate)
        @current.options.minDate = range.minDate
        @_saveSettings()
      else
        console.warn("chronos: Invalid minDate")

    if range.maxDate
      if @_isValidDate(range.maxDate)
        @current.options.maxDate = range.maxDate
        @_saveSettings()
      else
        console.warn("chronos: Invalid maxDate")
    @render() # re-render picker for new ranges



  ###
    Private Methods
  ###

  _initialize: ->
    # container div for the datepicker
    @_initializeContainer()
    # to animate the datepicker
    @_initializeAnimator()
    @_setStartingDate()
    @_setPickedDate()
    @_setInitialMode()

  _initializeContainer: ->
    @$container = @_createContainer()
    @_bindContainerEvents()
    @$container.append(@_createHeader.call(@))
    @$container.append(@_createBody.call(@))
    @$container

  _initializeAnimator: ->
    @animator = new chronos.Animator(@, @current.options.animations)
    @animator.setPicker(@$container)
    @animator

  # save the given date
  _saveDate: (date) ->
    @current.pickedDateTime = date
    @_saveSettings()

  # Determines the 'mode' to render for the picker
  # i.e. months, years, time, etc.
  _setInitialMode: ->
    if @current.options.useTimePicker && @current.options.timePickerOnly
      @mode = 'time'
    else if @current.options.yearOnly
      @mode = 'year'
    else
      @mode = 'month'

  # sets the picker's working date
  _setStartingDate: ->
    if @current.options.maxDate != null || @current.options.minDate != null
      # if today is past the max date, then set the working date to the max
      if @current.options.maxDate && (@todayDate.valueOf() > @current.options.maxDate.valueOf())
        @startingDate = new Date(@current.options.maxDate.valueOf())

      # if today is before the min date, then set the working date to the min
      if @current.options.minDate && (@todayDate.valueOf() < @current.options.minDate.valueOf())
        @startingDate = new Date(@current.options.minDate.valueOf())

    # set the working date to today (but a separate object) if still undefined
    if @startingDate == undefined
      @startingDate = new Date(@todayDate.valueOf())

    @startingDate

  # set's the pickers picked date if need be
  _setPickedDate: ->
    unless @current.options.startBlank
      if @current.pickedDateTime == undefined || @current.pickedDateTime == null
        @current.pickedDateTime = new Date(@startingDate.valueOf())

  # returns container div for picker
  _createContainer: ->
    klass = "chronos_picker"
    klass += " #{@current.options.pickerClass}" if @current.options.pickerClass
    $("<div class='#{klass}' />")

  # returns the header div for picker, which includes the title, and action buttons
  _createHeader: ->

    header = $('<div class="header"/>')

    header.append($('<div class="previous">&larr;</div>').click (event) =>
      @_onPrevious(event)
    )

    title = $('<div class="title"/>').click( (event) =>
      @_onZoomOut(event)
    )
    title.append($('<span class="titleText"/>'))
    header.append(title)

    header.append($('<div class="next">&rarr;</div>').click (event) =>
      @_onNext(event)
    )

    header

  # returns the main body div for the picker
  _createBody: ->
    body = $('<div class="body" />')
    body.append($('<div class="body_prev">'))
        .append($('<div class="body_curr">'))
        .append($('<div class="body_next">'))

  # Empty the panels
  _emptyBody: ->
    @$container.find(".body_curr").html("")
    @$container.find(".body_prev").html("")
    @$container.find(".body_next").html("")

  # set the picker's title to the given string
  _renderTitle: (titleStr) ->
    @$container.find('.titleText').html(titleStr)

  # _renderYears: ->
  #   # TODO

  # _renderTime: ->
  #   # TODO

  # fill the picker's body with a range of months to select from
  _renderMonths: ->
    start = @current.pickedDateTime || @startingDate # use pickedDateTime over startingDate
    @_buildMonth(start, @$container.find(".body_curr"))
    # set title to current month
    @_renderTitle(@$container.find(".body_curr").find(".monthBody").attr('data-date_title'))
    @_buildMonth(@_changeMonthBy(start, -1), @$container.find(".body_prev"))
    @_buildMonth(@_changeMonthBy(start, 1), @$container.find(".body_next"))

  # create a month panel according to given date and append it to given container
  _buildMonth: (showDate, $container) ->
    monthPanel = new chronos.PanelMonth(
      givenDate: showDate
      startDay: @current.options.startDay
      dayNamesAbbr: @current.options.dayNamesAbbr
      monthNames: @current.options.monthNames
      choice: @current.pickedDateTime
      maxDate: @current.options.maxDate
      minDate: @current.options.minDate
    )
    month = monthPanel.render()
    # handle day selection
    month.bind 'daySelected', (event, date, dayElement) =>
      @_onDaySelected(event, dayElement, date)
    $container.append(month)

  # Increment or decrement given date by given value in months
  _changeMonthBy: (date, value) ->
    d = new Date(date.valueOf())
    d.setMonth(d.getMonth() + value)
    d

  # Save View Element's Settings
  _saveSettings: ->
    $.data(@current.displayElement, chronos.Chronos.PROP_NAME, @current)

  # Update display input values with picked date
  _updateInputValues: ->
    @_updateValueElement()
    @_updateDisplayElement()

  # Update the value element according to the given format
  _updateValueElement: ->
     if @current.pickedDateTime
      d = @dateFormatter.format(@current.pickedDateTime, @current.options.valueFormat)
      @$valueElement.val(d)

  # Update the display element according to the given format
  _updateDisplayElement: ->
    if @current.pickedDateTime
      d = @dateFormatter.format(@current.pickedDateTime, @current.options.displayFormat)
      @$displayElement.val(d)

  # Return the window height
  _getWindowHeight: ->
    $(window).height()

  # Return the window's scroll length
  _getScrollTop: ->
    $(window).scrollTop()

  # Calculate the position on the screen at which to place the picker
  _getPosition: ->
    position =
      left: @$displayElement.offset().left + @current.options.positionOffset.left
      top: @$displayElement.offset().top + @current.options.positionOffset.top
    docHeight = @_getWindowHeight()
    scrollTop = @_getScrollTop()
    pickerHeight = @$container.outerHeight()
    lowerDifference = Math.abs(docHeight - position.top + @$displayElement.outerHeight())
    upperDifference = position.top + scrollTop
    displayBelow = lowerDifference > pickerHeight
    displayAbove = upperDifference > pickerHeight

    if not displayAbove && not displayBelow
      position.top = docHeight / 2 - pickerHeight / 2
      if (docHeight + scrollTop < pickerHeight)
        console.warn("chronos: Not enough room to display date picker.")
    else if displayBelow
      # display below takes priority over display above
      position.top += @$displayElement.outerHeight()
    else
      # display at offset above visual element
      position.top -= pickerHeight

    position

  # Return true if given a valid date
  _isValidDate: (d) ->
    Object.prototype.toString.call(d) == '[object Date]'



  ###
    EVENT HANDLERS
  ###

  # Handle header title clicks
  _onZoomOut: (event) ->
    console.log ("ZOOM!")

  # Handle previous button clicks
  _onPrevious: (event) ->
    @animator.previousMonth()

  # Handle next button clicks
  _onNext: (event) ->
    @animator.nextMonth()

  # Handle day selection
  _onDaySelected: (event, dayElement, date) ->
    unless @current.options.useTimePicker
      @current.pickedDateTime = date
      @_saveSettings()
      @_updateInputValues()
      # let Chronos manage closing picker, this event is not passed to the valueElement
      @$container.trigger('internal_close')
    else
      # TODO - pick time

  # Bind all container (picker) events to valueElement for easy access
  _bindContainerEvents: ->
    for eventType in chronos.Chronos.events
      @$container.on(eventType, (event) =>
        a = Array.prototype.slice.apply(arguments)
        @_passEvents(event, a.slice(1, a.length))
      )

  # responsible for passing all events to the valueElement for convenience and
  # to obey law of demeter. i.e. events should occur on valueElement and other objects
  # should be isolated from valueElement
  _passEvents: (event, args) ->
    event.stopPropagation()
    @$valueElement.trigger(event.type, args)




