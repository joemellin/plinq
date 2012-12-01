#= require_self
#= require_tree ./models
## require_tree ./views
#= require_tree ./routers

window.P =
  Routers: {}
  Views: {}
  initialize: (data) ->
    songs = new P.Songs(data.songs)
    new P.Routers.Router(songs: songs)
    Backbone.history.start()