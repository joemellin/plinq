class P.Routers.Router extends Backbone.Router
  initialize: (options) ->
    @songs = options.songs if options.songs?

  routes:
    '': 'index'
    'show/:id' : 'show'

  index: ->
    song = @songs.first() if @songs?
    if song?
      window.original_song_id = song.id
    else
      song = new P.Models.Song()
    P.keyboard = new P.Models.Keyboard(div_name: '#keyboard', song: song)
    P.keyboard.setup()
    P.songview = new P.Views.Song(song: song)

    #view = new P.Views.Keyboard()
    #$("#app").html(view.render().el)

  show: (id) ->
    console.log "show song with id #{id}"
