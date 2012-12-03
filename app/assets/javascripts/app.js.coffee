#= require_self
#= require_tree ./models
#= require_tree ./templates
#= require_tree ./views
#= require_tree ./routers
#= require hamlcoffee

window.P =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  initialize: (data) ->
    songs = new P.Collections.Songs(data.songs)
    data.song = new P.Models.Song(data.song) if data.song?
    P.user = if data.user? then new P.Models.User(data.user) else null
    P.router = new P.Routers.Router(songs: songs, song: data.song)
    P.show_play_modal = data.show_play_modal
    Backbone.history.start()
    #P.router.navigate('/')

$ ->
  $('#song_selector').change (e) ->
    window.location = $(this).val()