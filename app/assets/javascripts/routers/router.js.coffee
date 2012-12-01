class P.Routers.Router extends Backbone.Router
  initialize: (options) ->
    Backbone.history.start()

  routes:
    "" : "play"

  play: ->
    console.log 'play'
    window.keyboard = new P.Keyboard(div_name: '#keyboard')
    window.keyboard.setup()
    #view = new P.Views.Keyboard()
    #$("#app").html(view.render().el)