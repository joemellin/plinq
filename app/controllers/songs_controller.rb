class SongsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :played, :listened]
  load_and_authorize_resource :except => [:index]
  respond_to :html, :json

  def index
    @songs = Song.featured.asc(:created_at).limit(20)
    respond_with(@songs)
  end

  def show
    @songs = Song.featured.asc(:created_at).limit(20)
    @show_play_modal = (user_signed_in? && (@song.user.id == current_user.id)) ? true : false
    respond_to do |format|
      format.html { render :action => :song}
      format.json { render :json => @song }
    end
  end

  def create
    @song = Song.new(params[:song])
    @song.user = current_user if current_user.present?
    @song.save
    @song.share(current_user, params[:message], share_song_url(@song)) if params[:share].present?
    respond_with(@song)
  end

  def update
    @song.save
    respond_with(@song)
  end

  def destroy
    if @song.destroy
      respond_with :head => :ok
    else
      respond_with(:errors => @model.errors.full_messages, :status => 422)
    end
  end

  def share
    @song.share_on_facebook(current_user, url_for(:action => :show, :id => @song.id, :host => 'www.plinq.co'), params[:message])
    redirect_to @song
  end

  def played
    @song.increment_play_count!
    render :nothing => true
  end

  def listened
    @song.increment_listen_count!
    render :nothing => true
  end
end
