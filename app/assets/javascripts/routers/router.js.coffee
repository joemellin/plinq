class P.Routers.Router extends Backbone.Router
  initialize: (options) ->
    @songs = options.songs if options.songs?

  routes:
    '': 'index'
    'show/:id' : 'show'

  index: ->
    song = @songs.first() if @songs?
    song = new P.Models.Song() unless song
    window.keyboard = new P.Models.Keyboard(div_name: '#keyboard', song: song)
    window.keyboard.setup()
    #view = new P.Views.Keyboard()
    #$("#app").html(view.render().el)

  show: (id) ->
    console.log "show song with id #{id}"
