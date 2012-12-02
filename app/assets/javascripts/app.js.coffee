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
    P.user = if data.user? then new P.Models.User(data.user) else null
    P.router = new P.Routers.Router(songs: songs)
    Backbone.history.start()
    #P.router.navigate('/')