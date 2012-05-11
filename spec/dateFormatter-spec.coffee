describe "dateFormatter", ->
  c = new chronos.Chronos()
  df = new chronos.DateFormatter(c._defaultOptions)
  d = new Date("Thu May 11 2012 16:46:56 GMT-0400 (EDT)")

  describe "custom patterns", ->

    for patt in [{p: "m/dd/yy", v: "5/11/12"},
      {p: "dddd, mmmm dS, yyyy, h:MM:ss TT", v: "Friday, May 11th, 2012, 4:46:56 PM"}]

      it "such as '#{patt.p}' are handled correctly", ->
        expect(df.format(d, patt.p)).toEqual(patt.v)

  describe "named masks", ->
    for patt in [{p: "default", v: "Fri May 11 2012 16:46:56"},
      {p: "shortDate", v: "5/11/12"},
      {p: "mediumDate", v: "May 11, 2012"},
      {p: "longDate", v: "May 11, 2012"},
      {p: "fullDate", v: "Friday, May 11, 2012"},
      {p: "shortTime", v: "4:46 PM"},
      {p: "mediumTime", v: "4:46:56 PM"},
      {p: "longTime", v: "4:46:56 PM EST"},
      {p: "isoDate", v: "2012-05-11"},
      {p: "isoTime", v: "16:46:56"},
      {p: "isoDateTime", v: "2012-05-11T16:46:56"}]
      # testing isoUtcDateTime is not a good idea because of daylight savings changes
      it "such as '#{patt.p}' are handled correctly", ->
        expect(df.format(d, patt.p)).toEqual(patt.v)
