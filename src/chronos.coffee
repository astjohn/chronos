# This Class is responsible for managing the various datepickers that may be instantiated.
class Chronos

  constructor: () ->
    @current = {}
    @pickers = []
    @oldList = []
    @PROP_NAME = 'chronos_element_settings'



  _defaultOptions:
    pickerClass: 'wpd'
    days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
             'September', 'October', 'November', 'December']
    displayFormat: 'yyyy-mm-dd'
    valueFormat: 'U'


  ###
    PUBLIC METHODS
  ###

  # Set the manager's current settings to the given element
  # Pushes the current settings to the oldList to be dealt with later, i.e. closing
  # Requires an htmlElement
  setCurrentElement: (element) ->
    @oldList.push @current if @current
    @current = $.data(element, @PROP_NAME)

  setDateRange: (range) ->
    #console.log "WORKS"


  ###
    Private methods
  ###

  _attach: (element, options) ->
    @current =
      settings: $.extend({}, this._defaultOptions, options);
      valueElement: element

    p = new Picker(element)

    # store element specific instance properties, but must use the display_element
    # as that is the element which triggers onfocus
    #$.data($display_element[0], PROP_NAME, this.current);

  ###
    BINDINGS
  ###
