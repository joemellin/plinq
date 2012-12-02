class P.Views.Keyboard extends Backbone.View
  template: JST['templates/keyboard']

  initialize: (options) ->
    _.bindAll(this, 'render')
    @keyboard = options.keyboard
    @keyboard.bind 'change', => @render()
    @render()

  render: ->
    @.$el.html(@template())
    @