class P.Views.Song extends Backbone.View
  template: JST['templates/song']

  initialize: (options) ->
    _.bindAll(this, 'render')
    @song = options.song
    @song.bind 'change:at', => @render()
    @render()

  events: ->
    "click .shareButtonFinal": "share"
    "click .playRecordingButton": "playRecording"

  playRecording: ->
    @song.recordingSong.play() if @song.recordingSong?

  playSong: ->
    @song.play(true)

  share: ->
    @song.shareRecording()

  render: ->
    @.$el.html(@template(song: @song, user: P.user))
    $('.playSongButton').click =>
      @song.play(true)
    @