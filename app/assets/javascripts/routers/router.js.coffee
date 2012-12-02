class P.Routers.Router extends Backbone.Router
  routes:
    '': 'index'
    'show/:id': 'show'
    'leaderboard': 'leaderboard'

  initialize: (options) ->
    @songs = options.songs if options.songs?

  index: ->
    song = @songs.first() if @songs?
    if song?
      window.original_song_id = song.id
    else
      song = new P.Models.Song()

    P.keyboard = new P.Models.Keyboard(div_name: '#keyboard', song: song)
    P.keyboardView = new P.Views.Keyboard(el: $('#keyboard_wrapper'), keyboard: P.keyboard)
    P.keyboard.setup()
    P.songview = new P.Views.Song(el: $('#song_wrapper'), song: song)

    #view = new P.Views.Keyboard()
    #$("#app").html(view.render().el)

  show: (id) ->
    console.log "show song with id #{id}"

  leaderboard: ->
    P.leaderboardView = new P.Views.Leaderboard(el: $('#leaderboard'), songs: @songs)