class SongsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  load_and_authorize_resource :except => [:index]
  respond_to :html, :json

  def index
    @songs = Song.featured.asc(:created_at).limit(20)
    respond_with(@songs)
  end

  def show
    respond_with(@song)
  end

  def create
    @song = Song.new(params[:song])
    @song.user = current_user if current_user.present?
    @song.save
    respond_with(@song)
  end

  def update
    @song.save
    respond_with(@song)
  end

  def destroy
    @song.destroy
  end

  def share
    @song.share(current_user, params[:message], share_song_url(@song))
  end
end
