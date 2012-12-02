class P.Views.Leaderboard extends Backbone.View
  template: JST['templates/leaderboard']

  initialize: (options) ->
    _.bindAll(this, 'render')
    @songs = options.songs
    @render()

  render: ->
    @.$el.html(@template(users: @songs))
    @