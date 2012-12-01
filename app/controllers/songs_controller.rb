class SongsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  load_and_authorize_resource :except => [:index]
  respond_to :html, :json

  def index
    respond_with(Song.featured.asc(:created_at).limit(20))
  end

  def show
    respond_with(@song)
  end

  def create
    @song = Song.new(params[:song])
    #@song.user = current_user
    @song.save
    respond_with(song)
  end

  def update
    @song.save
    respond_with(@song)
  end

  def destroy
    @song.destroy
  end

  def share

  end
end
