describe "DateFormatter", ->
  c = new chronos.Chronos()
  df = new chronos.DateFormatter(chronos.Chronos._defaultOptions)
  d = new Date("Thu June 11 2012 16:46:56 GMT-0400 (EDT)")

  describe "#format", ->

    describe "when using custom patterns", ->

      for patt in [{p: "m/dd/yy", v: "6/11/12"},
        {p: "dddd, mmmm dS, yyyy, h:MM:ss TT", v: "Friday, June 11th, 2012, 4:46:56 PM"},
        {p: "d-m-yy", v: "11-6-12"}]

        it "such as '#{patt.p}' are handled correctly", ->
          expect(df.format(d, patt.p)).toEqual(patt.v)

    describe "when using named masks", ->
      for patt in [{p: "default", v: "Fri Jun 11 2012 16:46:56"},
        {p: "shortDate", v: "11/6/12"},
        {p: "USshortDate", v: "6/11/12"}
        {p: "mediumDate", v: "Jun 11, 2012"},
        {p: "longDate", v: "June 11, 2012"},
        {p: "fullDate", v: "Friday, June 11, 2012"},
        {p: "shortTime", v: "4:46 PM"},
        {p: "mediumTime", v: "4:46:56 PM"},
        {p: "longTime", v: "4:46:56 PM EST"},
        {p: "isoDate", v: "2012-06-11"},
        {p: "isoTime", v: "16:46:56"},
        {p: "isoDateTime", v: "2012-06-11T16:46:56"}]
        # testing isoUtcDateTime is not a good idea because of daylight savings changes
        it "such as '#{patt.p}' are handled correctly", ->
          expect(df.format(d, patt.p)).toEqual(patt.v)

  describe "#unformat", ->

    describe "when using custom masks", ->
      it "can make sense of the format and return a date", ->
        str = "June-16-1942 @ 03:44:43 AM"
        patt = "mmmm-dd-yyyy @ hh:MM:ss TT"
        d = df.newZeroDate()
        d.setMonth(5)
        d.setDate(16)
        d.setFullYear(1942)
        d.setHours(3)
        d.setMinutes(44)
        d.setSeconds(43)
        expect(df.unformat(str, patt).valueOf()).toEqual(d.valueOf())

    describe "when using named masks", ->
      beforeEach ->
        d = df.newZeroDate()

      it "can parse the 'default' format", ->
        str = "Fri May 11 2012 16:46:56"
        d.setDate(11)
        d.setMonth(4)
        d.setFullYear(2012)
        d.setHours(16)
        d.setMinutes(46)
        d.setSeconds(56)
        d.setMilliseconds(0)
        expect(df.unformat(str).valueOf()).toEqual(d.valueOf())

      it "cannot parse the 'shortDate' format because full year is needed", ->
        str = "5/11/12"
        expect(df.unformat(str, 'shortDate')).toEqual(false)

      it "cannot parse the 'USshortDate' format because full year is needed", ->
        str = "5/11/12"
        expect(df.unformat(str, 'USshortDate')).toEqual(false)

      it "can parse the 'mediumDate' format", ->
        str = "Jun 11, 2012"
        d.setDate(11)
        d.setMonth(5)
        d.setFullYear(2012)
        expect(df.unformat(str, 'mediumDate').valueOf()).toEqual(d.valueOf())

      it "can parse the 'longDate' format", ->
        str = "June 11, 2012"
        d.setDate(11)
        d.setMonth(5)
        d.setFullYear(2012)
        expect(df.unformat(str, 'longDate').valueOf()).toEqual(d.valueOf())

      it "can parse the 'fullDate' format", ->
        str = "Friday, June 11, 2012"
        d.setDate(11)
        d.setMonth(5)
        d.setFullYear(2012)
        expect(df.unformat(str, 'fullDate').valueOf()).toEqual(d.valueOf())

      it "can parse the 'shortTime' format", ->
        str = "4:46 PM"
        d.setHours(16)
        d.setMinutes(46)
        expect(df.unformat(str, 'shortTime').valueOf()).toEqual(d.valueOf())

      it "can parse the 'mediumTime' format", ->
        str = "4:46:56 PM"
        d.setHours(16)
        d.setMinutes(46)
        d.setSeconds(56)
        expect(df.unformat(str, 'mediumTime').valueOf()).toEqual(d.valueOf())

      it "cannot parse the 'longTime' format because it can't handle timezones", ->
        str = "4:46:56 PM EST"
        expect(df.unformat(str, 'mediumTime').valueOf()).toEqual(false)

      it "can parse the 'isoDate' format", ->
        str = "2012-06-11"
        d.setDate(11)
        d.setMonth(5)
        d.setFullYear(2012)
        expect(df.unformat(str, 'isoDate').valueOf()).toEqual(d.valueOf())

      it "can parse the 'isoTime' format", ->
        str = "16:46:56"
        d.setHours(16)
        d.setMinutes(46)
        d.setSeconds(56)
        expect(df.unformat(str, 'isoTime').valueOf()).toEqual(d.valueOf())

      it "cannot parse the 'isoDateTime' format", ->
        str = "2012-06-11T16:46:56"
        expect(df.unformat(str, 'isoTime')).toEqual(false)

      it "returns false if mask does not match string input", ->
        str = "June 15, 2012"
        expect(df.unformat(str, 'mm d, y')).toEqual(false)
