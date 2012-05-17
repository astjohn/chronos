# Inspiration and some code from:
# http://blog.stevenlevithan.com/archives/date-time-format
#
#  Date Format 1.2.3
#  (c) 2007-2009 Steven Levithan <stevenlevithan.com>
#  MIT license
#
#  Includes enhancements by Scott Trenda <scott.trenda.net>
#  and Kris Kowal <cixar.com/~kris.kowal/>
#
#  Accepts a date, a mask, or a date and a mask.
#  Returns a formatted version of the given date.
#  The date defaults to the current date/time.
#  The mask defaults to dateFormat.masks.default.
#
class chronos.DateFormatter

  constructor: (settings) ->
    @i18n =
      dayNames: settings.dayNames
      monthNames: settings.monthNames
      amLower: settings.amLower
      amUpper: settings.amUpper
      amAbbr: settings.amAbbr
      pmLower: settings.pmLower
      pmUpper: settings.pmUpper
      pmAbbr: settings.pmAbbr

  masks:
    default: "ddd mmm dd yyyy HH:MM:ss"
    shortDate: "d/m/yy"
    USshortDate: "m/d/yy"
    mediumDate: "mmm d, yyyy"
    longDate: "mmmm d, yyyy"
    fullDate: "dddd, mmmm d, yyyy"
    shortTime: "h:MM TT"
    mediumTime: "h:MM:ss TT"
    longTime: "h:MM:ss TT Z"
    isoDate: "yyyy-mm-dd"
    isoTime: "HH:MM:ss"
    isoDateTime: "yyyy-mm-dd'T'HH:MM:ss"
    isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"

  token: /U{1}|d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g
  timezone: /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g
  timezoneClip: /[^-+\dA-Z]/g

  pad: (val, len) ->
    val = String(val)
    len = len or 2
    val = "0" + val  while val.length < len
    val

  newZeroDate: ->
    d = new Date()
    d.setDate(0)
    d.setMonth(0)
    d.setFullYear(0)
    d.setHours(0)
    d.setMinutes(0)
    d.setSeconds(0)
    d.setMilliseconds(0)
    d

  unformat: (dateStr, mask, utc) ->
    # milliseconds, seconds, minutes, hours, day, month, year, timezone
    dF = @

    mask = String(dF.masks[mask] or mask or dF.masks["default"])
    date = @newZeroDate()
    date.setHours(0)
    maskParts = mask.split(/\W+/)
    dateParts = dateStr.split(/\W+/)
    notCounter = 0

    _ = (if utc then "setUTC" else "set")
    __ = (if utc then "getUTC" else "get")

    for i in [0..maskParts.length-1]
      targetMask = maskParts[i]
      target = dateParts[i]

      switch (targetMask)
        when 'd', 'dd' then date[_ + 'Date'](target)
        when 'ddd', 'dddd' then null # do nothing
        when 'm', 'mm' then date[_ + 'Month'](parseInt(target)-1)
        when 'mmm' then date[_ + 'Month'](dF.i18n.monthNames.indexOf(target))
        when 'mmmm' then date[_ + 'Month'](dF.i18n.monthNames.indexOf(target)-12)
        #when 'yy'  # need full year so do not perform
        when 'yyyy' then date[_ + 'FullYear'](target)
        when 'h', 'hh' then date[_ + 'Hours'](target % 12 or 12) # add 12 hours if PM below
        when 'H' , 'HH' then date[_ + 'Hours'](target)
        when 'M' , 'MM' then date[_ + 'Minutes'](target)
        when 's', 'ss' then date[_ + 'Seconds'](target)
        when 'l' , 'L' then date[_ + 'Milliseconds'](target)
        when 't'
          if dF.i18n.pmAbbrLower == target
            # need to add 12 hours to time
            date[_ + 'Hours'](date[__ + 'Hours']() + 12)
        when 'tt'
          if dF.i18n.pmLower == target
            # need to add 12 hours to time
            date[_ + 'Hours'](date[__ + 'Hours']() + 12)
        when 'T'
          if dF.i18n.pmAbbrUpper == target
            # need to add 12 hours to time
            date[_ + 'Hours'](date[__ + 'Hours']() + 12)
        when 'TT'
          if dF.i18n.pmUpper == target
            # need to add 12 hours to time
            date[_ + 'Hours'](date[__ + 'Hours']() + 12)
        when 'Z' then null # do not handle time zones
        when 'U' then date[_ + 'Time'](target) # yeah, right.
        else
          notCounter += 1

    if (notCounter > 0 || maskParts.length != dateParts.length)
      false
    else
      date

  format: (date, mask, utc) ->
    dF = @
    args = arguments

    # Regexes and supporting functions are cached through closure
    ( ->

      # You can't provide utc if you skip other args (use the "UTC:" mask prefix)
      if args.length is 1 and Object::toString.call(date) is "[object String]" and not /\d/.test(date)
        mask = date
        date = undefined

      # Passing date through Date applies Date.parse, if necessary
      date = if date then new Date(date) else new Date
      throw SyntaxError("invalid date") if isNaN(date)
      mask = String(dF.masks[mask] or mask or dF.masks["default"])
      if mask.slice(0, 4) is "UTC:"
        mask = mask.slice(4)
        utc = true

      _ = (if utc then "getUTC" else "get")
      d = date[_ + "Date"]()
      D = date[_ + "Day"]()
      m = date[_ + "Month"]()
      y = date[_ + "FullYear"]()
      H = date[_ + "Hours"]()
      M = date[_ + "Minutes"]()
      s = date[_ + "Seconds"]()
      L = date[_ + "Milliseconds"]()
      o = (if utc then 0 else date.getTimezoneOffset())
      U = date.valueOf()

      flags =
        d: d
        dd: dF.pad(d)
        ddd: dF.i18n.dayNames[D]
        dddd: dF.i18n.dayNames[D + 7]
        m: m + 1
        mm: dF.pad(m + 1)
        mmm: dF.i18n.monthNames[m]
        mmmm: dF.i18n.monthNames[m + 12]
        yy: String(y).slice(2)
        yyyy: y
        h: H % 12 or 12
        hh: dF.pad(H % 12 or 12)
        H: H
        HH: dF.pad(H)
        M: M
        MM: dF.pad(M)
        s: s
        ss: dF.pad(s)
        l: dF.pad(L, 3)
        L: dF.pad((if L > 99 then Math.round(L / 10) else L))
        t: (if H < 12 then dF.i18n.amAbbrLower else dF.i18n.pmAbbrLower)
        tt: (if H < 12 then dF.i18n.amLower else dF.i18n.pmLower)
        T: (if H < 12 then dF.i18n.amAbbrUpper else dF.i18n.pmAbbrUpper)
        TT: (if H < 12 then dF.i18n.amUpper else dF.i18n.pmUpper)
        Z: (if utc then "UTC" else (String(date).match(dF.timezone) or [ "" ]).pop().replace(dF.timezoneClip, ""))
        o: (if o > 0 then "-" else "+") + dF.pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4)
        S: [ "th", "st", "nd", "rd" ][(if d % 10 > 3 then 0 else (d % 100 - d % 10 isnt 10) * d % 10)]
        U: U

      mask.replace dF.token, ($0) ->
        (if $0 of flags then flags[$0] else $0.slice(1, $0.length - 1))
    )()



