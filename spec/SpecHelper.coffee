beforeEach( ->
  this.addMatchers
    toBePlaying: (expectedSong) ->
      player = this.actual
      player.currentlyPlayingSong == expectedSong && player.isPlaying
)

newDefaultPicker = ->
  current =
    valueElement: $("<input />")
    options: chronos.Chronos._defaultOptions
    displayElement: $("<input />")
  new chronos.Picker(current)


