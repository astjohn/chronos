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
    shortDate: "m/d/yy"
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

  format: (date, mask, utc) ->
    token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g
    timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g
    timezoneClip = /[^-+\dA-Z]/g
    pad = (val, len) ->
      val = String(val)
      len = len or 2
      val = "0" + val  while val.length < len
      val
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

      flags =
        d: d
        dd: pad(d)
        ddd: dF.i18n.dayNames[D]
        dddd: dF.i18n.dayNames[D + 7]
        m: m + 1
        mm: pad(m + 1)
        mmm: dF.i18n.monthNames[m]
        mmmm: dF.i18n.monthNames[m + 12]
        yy: String(y).slice(2)
        yyyy: y
        h: H % 12 or 12
        hh: pad(H % 12 or 12)
        H: H
        HH: pad(H)
        M: M
        MM: pad(M)
        s: s
        ss: pad(s)
        l: pad(L, 3)
        L: pad((if L > 99 then Math.round(L / 10) else L))
        t: (if H < 12 then dF.i18n.amAbbrLower else dF.i18n.pmAbbrLower)
        tt: (if H < 12 then dF.i18n.amLower else dF.i18n.pmLower)
        T: (if H < 12 then dF.i18n.amAbbrUpper else dF.i18n.pmAbbrUpper)
        TT: (if H < 12 then dF.i18n.amUpper else dF.i18n.pmUpper)
        Z: (if utc then "UTC" else (String(date).match(timezone) or [ "" ]).pop().replace(timezoneClip, ""))
        o: (if o > 0 then "-" else "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4)
        S: [ "th", "st", "nd", "rd" ][(if d % 10 > 3 then 0 else (d % 100 - d % 10 isnt 10) * d % 10)]

      mask.replace token, ($0) ->
        (if $0 of flags then flags[$0] else $0.slice(1, $0.length - 1))
    )()

