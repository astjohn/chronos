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
    animationPrepare = @animations.previousMonthPrepare || @_animatePreviousMonthPrepare
    animation = @animations.previousMonth || @_animatePreviousMonth
    animationCallback = @animations.previousMonthCallback || @_animatePreviousMonthCallback
    @_animate(animationPrepare, animation, animationCallback, 'previousMonthFinished')

  # Animate shift to next month
  nextMonth: ->
    animationPrepare = @animations.nextMonthPrepare || @_animateNextMonthPrepare
    animation = @animations.nextMonth || @_animateNextMonth
    animationCallback = @animations.nextMonthCallback || @_animateNextMonthCallback
    @_animate(animationPrepare, animation, animationCallback, 'nextMonthFinished')

  ###
    Private Methods
  ###

  # common animation pattern
  _animate: (before, animation, after, eventName) ->
    unless @animating
      @animating = true
      before.apply(@, [@pickerManager])
      $.when(animation.apply(@, [@pickerManager])).always =>
        $.when(after.apply(@, [@pickerManager])).always =>
          @animating = false
          @$picker.trigger(eventName)

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
    width = @$curr.outerWidth()
    @$curr.animate {
      left: "+=#{width}"
    }, 500
    @$prev.animate {
      left: "+=#{width}"
    }, 500

  # default action to before previous month animation
  _animatePreviousMonthPrepare: (pickerManager) ->
    pickerManager._renderTitle(@$prev.find(".monthBody").attr('data-date_title'))

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

    newCurrentDate = new Date(parseInt(@$prev.find(".monthBody").attr('data-date')))
    pickerManager._buildMonth(pickerManager._changeMonthBy(newCurrentDate, -1), $new_prev)

  # default action for next month animation
  _animateNextMonth: (pickerManager) ->
    width = @$curr.outerWidth()
    @$curr.animate {
      left: "-=#{width}"
    }, 500
    @$next.animate {
      left: "-=#{width}"
    }, 500

  # default action to before next month animation
  _animateNextMonthPrepare: (pickerManager) ->
    pickerManager._renderTitle(@$next.find(".monthBody").attr('data-date_title'))

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

    newCurrentDate = new Date(parseInt(@$next.find(".monthBody").attr('data-date')))
    pickerManager._buildMonth(pickerManager._changeMonthBy(newCurrentDate, 1), $new_next)







