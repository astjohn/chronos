# This datepicker uses a singleton pattern to manage all possible datepickers on a given page.
( ($, window, document) ->

  ###
    DATEPICKER PLUGIN DEFINITION
  ###
  $.fn.chronos = (options) ->

    PROP_NAME = 'chronos'
    otherArgs = Array.prototype.slice.call(arguments, 1)

    # check to see if we have already instantiated a chronos picker on the
    # given element
    @each( ->
      element = @
      $element = $(@)
      $display = $("##{$element.attr('id')}_display")
      current = $.data(element, PROP_NAME)

      if typeof options == 'string'
        unless $.chronos[options]
          console.error("chronos: Unknown command: " + options)
          return null
        else
          # indirect access to chronos method
          if current
            if $display.length > 0
              # set current element from displayElement
              $.chronos['setCurrentElement'].apply($.chronos, [$display[0]])
              $.chronos[options].apply($.chronos, otherArgs) # call public method
            else
              console.warn("chronos: Unknown datepicker.  Make sure id attribute is present")
          else
            console.warn("chronos: Unknown datepicker.")

      else
        # Only instantiate a date picker if we don't already have one
        unless current
          $.chronos._attach(element, options || {})
          $.data(element, PROP_NAME, true)
    )

    ###
      PUBLIC METHODS (direct access)

      New public methods must make sure to set the current element first through the
      pluginSetCurrentElement function.
    ###
    @setDateRange = (range) ->
      _pluginSetCurrentElement.apply(@)
      $.chronos.setDateRange(range)
      @

    @setDate = (d) ->
      _pluginSetCurrentElement.apply(@)
      $.chronos.setDate(d)
      @

    @clearDate = ->
      _pluginSetCurrentElement.apply(@)
      $.chronos.clearDate()
      @


    ###
      PRIVATE METHODS
    ###

    _pluginSetCurrentElement = ->
      $display = $("##{@.attr('id')}_display")
      $.chronos.setCurrentElement($display[0]) if $display.length > 0


    # return this for method chaining
    @

  # Singleton instance
  $.chronos = new chronos.Chronos();


)(jQuery || Zepto, window, document)
