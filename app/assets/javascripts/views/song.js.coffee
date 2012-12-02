class P.Views.Song extends Backbone.View
  template: JST['templates/song']

  initialize: (options) ->
    _.bindAll(this, 'render')
    @song = options.song
    @song.bind 'change', => @render()
    @render()

  events: ->
      "click .share" : "share"

  share: ->
    window.location = "/songs/#{@song.id}/share"

  render: ->
    @.$el.html(@template(song: @song, user: P.user))
    @