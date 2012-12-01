#= require_self
#= require_tree ./models
#= require_tree ./routers

window.P =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  initialize: (data) ->
    songs = new P.Collections.Songs(data.songs)
    new P.Routers.Router(songs: songs)
    Backbone.history.start()