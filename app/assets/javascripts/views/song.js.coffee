class P.Views.Song extends Backbone.View
  template: JST['templates/song']

  initialize: (options) ->
    _.bindAll(this, 'render')
    @song = options.song
   # @song.bind 'change', => @render()
    @song.bind 'change:at', => @render()
    @render()

  events: ->
      "click .shareButton" : "share"

  share: ->
    @song.shareRecording()

  render: ->
    @.$el.html(@template(song: @song, user: P.user))
    @