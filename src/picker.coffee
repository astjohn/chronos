class chronos.Picker

  constructor: (current) ->
    @current = current
    @container = undefined
    @workingDate = undefined
    @todayDate = new Date()
    #@pickedDate = new Date()

    @_initialize()





  ###
    Public Methods
  ###



  ###
    Private Methods
  ###

  _initialize: ->
    @container ||= @_initializeContainer()
    @_setWorkingDate()

  _initializeContainer: ->
    @container = @_createContainer()
    @container.append(@_createHeader.call(@))
    @container.append(@_createBody.call(@))

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

    header.append($('<div class="close">x</div>').click (event) =>
      @_onClose(event)
    )

    header

  # returns the main body div for the picker
  _createBody: ->
    body = $('<div class="body" />')
    body.append($('<div class="body_prev">'))
        .append($('<div class="body_curr">'))
        .append($('<div class="body_next">'))

  # set the picker's title to the given string
  _renderTitle: (titleStr) ->
    @container.find('.titleText').html(titleStr)

  # fill the picker's body with a range of years to select from
  _renderYears: ->


    # while(this.current.working_date.getFullYear() % this.current.settings.yearsPerPage > 0) {
    #   this.current.working_date.setFullYear(this.current.working_date.getFullYear() - 1);
    # }

            # this._renderTitle(this.current.working_date.getFullYear() + '-' +
        #     (this.current.working_date.getFullYear() + this.current.settings.yearsPerPage - 1));

    #@_renderTitle("#{workingDate.getFullYear()} - #{workingDate.getFullYear + @current.options.yearsPerPage - 1}")











  # fill the picker's body with a range of months to select from
  _renderMonths: ->
    month = @workingDate.getMonth()
    # add 12 to month names to get full name
    @_renderTitle("#{@current.options.monthNames[month+12]} #{@workingDate.getFullYear()}")

    currentMonthPanel = new chronos.PanelMonth(
      givenDate: @workingDate
      month: @workingDate.getMonth()
      startDay: @current.options.startDay
      dayNamesAbbr: @current.options.dayNamesAbbr
      choice: undefined # TODO
      maxDate: undefined # TODO
      minDate: undefined # TODO
    )

    currentMonth = currentMonthPanel.render()

    # handle day selection
    currentMonth.bind 'daySelect', (event, dayElement, date) =>
      @_onDaySelect(event, dayElement, date)

    @container.find(".body_curr").append(currentMonth)































  # sets the picker's working date
  _setWorkingDate: ->
    if @current.options.maxDate != null || @current.options.minDate != null


      # if today is past the max date, then set the working date to the max
      if @current.options.maxDate && (@todayDate.valueOf() > @current.options.maxDate.valueOf())
        @workingDate = new Date(@current.options.maxDate.valueOf())

      # if today is before the min date, then set the working date to the min
      if @current.options.minDate && (@todayDate.valueOf() < @current.options.minDate.valueOf())
        @workingDate = new Date(@current.options.minDate.valueOf())

    # set the working date to today (but a separate object) if still undefined
    if @workingDate == undefined
      @workingDate = new Date(@todayDate.valueOf())
    @workingDate


  ###
    EVENT HANDLERS
  ###

  _onZoomOut: (event) ->
    console.log ("ZOOM!")

  _onPrevious: (event) ->

  _onNext: (event) ->

  _onClose: (event) ->

  _onDaySelect: (event, dayElement, date) ->
    console.log "SELECTED", event, dayElement, date




