class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    redirect_to '/'
  end
end
