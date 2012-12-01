class P.Routers.Router extends Backbone.Router
  #initialize: (options) ->

  routes:
    '': 'index'
    'show/:id' : 'show'

  index: ->
    song = new P.Models.Song()
    window.keyboard = new P.Models.Keyboard(div_name: '#keyboard', song: song)
    window.keyboard.setup()
    #view = new P.Views.Keyboard()
    #$("#app").html(view.render().el)

  show: (id) ->
    console.log "show song with id #{id}"
