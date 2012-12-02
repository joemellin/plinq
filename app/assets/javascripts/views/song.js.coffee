class P.Views.Song extends Backbone.View
  template: JST['templates/song']
  id: 'song_wrapper'

  constructor: (attr) ->
    super attr
    @song = attr.song
    @song.bind 'change', => @render()
    @render()

  events: ->
      "click .share" : "share"

  share: ->
    window.location = "/songs/#{@song.id}/share"

  render: ->
    @.$el.html(@template(song: @song, user: P.user))
    @