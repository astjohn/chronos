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
      current = $.data(element, PROP_NAME)

      if typeof options == 'string'
        unless $.chronos[options]
          console.error("chronos: Unknown command: " + options)
          return null
        else
          if (current)
            $.chronos['setCurrentElement'].apply($.chronos, [element])
            $.chronos[options].apply($.chronos, otherArgs)
          else
            console.warn("chronos: Unknown datepicker.")

      else
        # Only instantiate a date picker if we don't already have one
        unless current
          $.chronos._attach(element, options || {})
          $.data(element, PROP_NAME, true)
    )

    ###
      PUBLIC METHODS

      New public methods must make sure to set the current element first through the
      pluginSetCurrentElement function.
    ###
    @setDateRange = (range) ->
      pluginSetCurrentElement.apply(@)
      $.chronos.setDateRange(range)
      @

    ###
      PRIVATE METHODS
    ###
    pluginSetCurrentElement = ->
      $.chronos.setCurrentElement(@[0])

    # return this for method chaining
    @


  # Singleton instance
  $.chronos = new Chronos();


)(jQuery || Zepto, window, document)
