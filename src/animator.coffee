# responsible for performing various animations for a given chronos picker
class chronos.Animator

  constructor: (pickerManager, animations) ->
    @pickerManager = pickerManager
    @animating = false # flag to prevent multiple actions occurring at one time
    @animations = animations
    @$picker = undefined
    @$body = undefined
    @$next = undefined
    @$curr = undefined
    @$prev = undefined

  # set the picker to animate
  setPicker: ($picker) ->
    @$picker = $picker
    @_setElements()

  # Animate shift to previous month
  previousMonth: ->
    animation = @animations.previousMonth || @_animatePreviousMonth
    @_animate(animation, 'previousMonthFinished')

  # Animate shift to next month
  nextMonth: ->
    animation = @animations.nextMonth || @_animateNextMonth
    @_animate(animation, 'nextMonthFinished')

  # Animate closing the date picker
  close: ->
    animation = @animations.close || @_animateClose
    @_animate(animation, 'closed', true)

  # Animate opening the date picker
  open: ->
    animation = @animations.open || @_animateOpen
    @_animate(animation, 'opened')

  # callback used to set animation to finished
  # Note: Custom animations must call this function at the end of their routine
  #       by this.animationFinished()
  animationFinished: ->
    @animating = false
    @$picker.trigger(@currentEventName) if @currentEventName
    @currentEventName = null

  ###
    Private Methods
  ###

  # common animation pattern
  _animate: (animation, eventName, override) ->
    @animating = false if override
    unless @animating
      @animating = true
      @currentEventName = eventName

      if $.isFunction(animation)
        animation.apply(@, [@pickerManager])

  # set the body, next, current, and previous elements for given picker
  _setElements: ->
    @$body = @$picker.find(".body")
    @$next = @$body.find(".body_next")
    @$curr = @$body.find(".body_curr")
    @$prev = @$body.find(".body_prev")

  ###
    Default Animations
  ###

  # Default animation for previous month
  _animatePreviousMonth: (pickerManager) ->
    pickerManager._renderTitle(@$prev.find(".monthBody").attr('data-date_title'))
    width = @$curr.outerWidth()
    @$curr.animate {
      left: "+=#{width}"
    }, 500
    @$prev.animate {
      left: "+=#{width}"
    }, 500, =>
      @_animatePreviousMonthCallback(pickerManager)
      @animationFinished()

  # default actions to perform after previous month animation
  _animatePreviousMonthCallback: (pickerManager) ->
    # when finished:
    #  - remove next
    #  - set current to next
    #  - set prev to current
    #  - build new MonthPanel for prev
    @$next.remove()
    @$curr.removeClass("body_curr").addClass("body_next")
    @$prev.removeClass("body_prev").addClass("body_curr")
    $new_prev = $("<div class='body_prev' />")
    @$body.prepend($new_prev)

    @$curr.removeAttr('style')
    @$prev.removeAttr('style')
    @$next.removeAttr('style')

    newCurrentDate = new Date(parseInt(@$prev.find(".monthBody").attr('data-date'), 10))
    pickerManager._buildMonth(pickerManager._changeMonthBy(newCurrentDate, -1), $new_prev)
    @_setElements()

  # default action for next month animation
  _animateNextMonth: (pickerManager) ->
    pickerManager._renderTitle(@$next.find(".monthBody").attr('data-date_title'))
    width = @$curr.outerWidth()
    @$curr.animate {
      left: "-=#{width}"
    }, 500
    @$next.animate {
      left: "-=#{width}"
    }, 500, =>
      @_animateNextMonthCallback(pickerManager)
      @animationFinished()

  # default actions to perform after next month animation
  _animateNextMonthCallback: (pickerManager) ->
    # when finished:
    #  - remove prev
    #  - set current to prev
    #  - set next to current
    #  - build new MonthPanel for next
    @$prev.remove()
    @$curr.removeClass("body_curr").addClass("body_prev")
    @$next.removeClass("body_next").addClass("body_curr")
    $new_next = $("<div class='body_next' />")
    @$body.append($new_next)

    @$curr.removeAttr('style')
    @$prev.removeAttr('style')
    @$next.removeAttr('style')

    newCurrentDate = new Date(parseInt(@$next.find(".monthBody").attr('data-date'), 10))
    pickerManager._buildMonth(pickerManager._changeMonthBy(newCurrentDate, 1), $new_next)
    @_setElements()

  # default animation to close picker
  _animateClose: (pickerManager) ->
    @$picker.animate {
      opacity: 0
    }, 300, =>
      @$picker.remove()
      @animationFinished()

  # default animation to close picker
  _animateOpen: (pickerManager) ->
    @$picker.fadeIn('fast', =>
      @animationFinished()
    )







