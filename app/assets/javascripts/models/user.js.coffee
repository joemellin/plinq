class P.Models.User extends Backbone.Model
  urlRoot: '/songs'

class P.Collections.Users extends Backbone.Collection
  model: P.Models.User
  url: '/users'