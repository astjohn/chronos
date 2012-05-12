class chronos.PanelMonth

  constructor: (options) ->
    @givenDate = new Date(options.givenDate.valueOf()) # do not mutate original
    @month = options.month
    @startDay = options.startDay
    @dayNamesAbbr = options.dayNamesAbbr
    @choice = options.choice
    @maxDate = options.maxDate
    @minDate = options.minDate
    @today = new Date()
    @container = {}

  render: ->
    @container = $("<div class='monthPanel' />")
    @container.append(@_getMonthHeader.call(@))
    @container.append(@_getMonthDays.call(@))
    @container

  ###
    Private Methods
  ###

  # Creates a date representing the start of the calendar month panel
  # first set given date to beginning of month
  # then iterate backwards until we have found the start day as specified in options
  # eg. sunday, monday, etc.
  # this will traverse through days in previous month if need be
  _getMonthStart: ->
    d = new Date(@givenDate)
    d.setDate(1);
    while d.getDay() != @startDay
      d.setDate(d.getDate() - 1)
    d

  # create and return a div containing the month header days
  _getMonthHeader: ->
    titles = $('<div class="monthHeader" />')
    for d in [@startDay..@startDay+6]
      klass = "title day day#{(d % 7)}"
      value = @dayNamesAbbr[(d % 7)]
      titles.append($("<div class='#{klass}'>#{value}</div>"))
      d++
    titles

  # Return true if given date matches today's date
  # Given date should have time portion set to zero
  _isToday: (d) ->
    today = new Date(@today.valueOf())
    @_clearTimePortion(today)
    d.toDateString() == today.toDateString()

  # Return true if given date matches choice
  # Given date should have time portion set to zero.
  _isChoice: (d) ->
    if @choice
      choice = new Date(@choice.valueOf())
      @_clearTimePortion(choice)
      d.toDateString() == choice.toDateString()
    else
      false

  # Return true if given date matches @month
  _isMonth: (d) ->
    @month == d.getMonth()

  # Return true if date is available according to maxDate and minDate
  # maxDate and minDate are inclusive and have already had their time portions zeroed
  _isAvailable: (d) ->
    return true unless (@maxDate != undefined || @minDate != undefined)
    if @maxDate && @minDate
      (d.valueOf() >= @minDate.valueOf()) && (d.valueOf() <= @maxDate.valueOf())
    else if @maxDate
      d.valueOf() <= @maxDate.valueOf()
    else
      # only min
      d.valueOf() >= @minDate.valueOf()

  # Mutates given date to clear time portion
  _clearTimePortion: (d) ->
    d.setHours(0)
    d.setMinutes(0)
    d.setMilliseconds(0)
    d

  # build the month days
  _getMonthDays: ->
    days = $("<div class='monthBody' />")
    workingDate = @_getMonthStart()

    # zero out time portion of dates before doing any comparisons
    @_clearTimePortion(workingDate)
    if @choice
      checkChoice = new Date(@choice.valueOf()) # do not mutate original
      @_clearTimePortion(checkChoice)
    if @maxDate
      @maxDate = new Date(@maxDate.valueOf()) # do not mutate original
      @_clearTimePortion(@maxDate)
    if @minDate
      @minDate = new Date(@minDate.valueOf()) # do not mutate original
      @_clearTimePortion(@minDate)

    for d in [0..41]
      classes = ['day', 'day' + workingDate.getDay()]
      classes.push('today') if @_isToday(workingDate)
      classes.push('selected') if @_isChoice(checkChoice)
      classes.push('otherMonth') unless @_isMonth(workingDate)
      classes.push('unavailable') unless @_isAvailable(workingDate)

      # add week container when appropriate
      if d % 7 == 0
        weekNumber = Math.floor(d / 7)
        weekContainer = $("<div class='week week#{weekNumber}' />")
        days.append(weekContainer)

      # create day div
      classes = classes.join(' ')
      day = $("<div class='#{classes}' >#{workingDate.getDate()}</div>")

      day.click {date: new Date(workingDate.valueOf())}, (event) =>
        @_onDaySelect(event, event.data.date)
      weekContainer.append(day)

      # increment day
      workingDate.setDate(workingDate.getDate() + 1)

    days

  # Fire daySelect
  _onDaySelect: (event, date) ->
    @container.trigger('daySelect', [event.target, date])




