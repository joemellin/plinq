class P.Routers.Router extends Backbone.Router
  #initialize: (options) ->

  routes:
    '': 'index'
    'show/:id' : 'show'

  index: ->
    console.log 'play'
    window.keyboard = new P.Keyboard(div_name: '#keyboard')
    window.keyboard.setup()
    #view = new P.Views.Keyboard()
    #$("#app").html(view.render().el)

  show: (id) ->
    console.log "show song with id #{id}"
