class chronos.Picker

  constructor: (current) ->
    @current = current # to reference and save picker's settings
    @container = undefined # to hold the picker
    @startingDate = undefined # the start date to show
    @todayDate = new Date() # for today
    @pickedDateTime = undefined
    @animator = undefined

    @_initialize()





  ###
    Public Methods
  ###



  ###
    Private Methods
  ###

  _initialize: ->
    @container ||= @_initializeContainer()
    @animator ||= new chronos.Animator(@, @current.options.animations)
    @_setStartingDate()

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
    @_buildMonth(@startingDate, @container.find(".body_curr"))

    # set title to current month
    @_renderTitle(@container.find(".body_curr").find(".monthBody").attr('data-date_title'))

    @_buildMonth(@_changeMonthBy(@startingDate, -1), @container.find(".body_prev"))

    @_buildMonth(@_changeMonthBy(@startingDate, 1), @container.find(".body_next"))

  # create a month panel according to given date and append it to given container
  _buildMonth: (showDate, $container) ->
    monthPanel = new chronos.PanelMonth(
      givenDate: showDate
      startDay: @current.options.startDay
      dayNamesAbbr: @current.options.dayNamesAbbr
      monthNames: @current.options.monthNames
      choice: @pickedDateTime #new Date("2012-05-16") # TODO
      maxDate: undefined # TODO
      minDate: undefined # TODO
    )
    month = monthPanel.render()
    # handle day selection
    month.bind 'daySelect', (event, dayElement, date) =>
      @_onDaySelect(event, dayElement, date)
    $container.append(month)

  # Increment or decrement given date by given value in months
  _changeMonthBy: (date, value) ->
    d = new Date(date.valueOf())
    d.setMonth(d.getMonth() + value)
    d

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


  ###
    EVENT HANDLERS
  ###

  _onZoomOut: (event) ->
    console.log ("ZOOM!")

  _onPrevious: (event) ->
    console.log "previous!", event
    $picker = $(event.target).parent().parent(".chronos_picker")
    @animator.setPicker($picker)
    @animator.previousMonth()

  _onNext: (event) ->
    console.log "next!", event
    $picker = $(event.target).parent().parent(".chronos_picker")
    @animator.setPicker($picker)
    @animator.nextMonth()

  _onClose: (event) ->
    console.log ("close!")


  _onDaySelect: (event, dayElement, date) ->
    console.log "SELECTED", event, dayElement, date
    #@pickedDateTime = date




