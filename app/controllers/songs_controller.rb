class SongsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :played, :listened, :create]
  load_and_authorize_resource :except => [:index]
  respond_to :html, :json

  def index
    load_songs
    respond_with(@songs)
  end

  def show
    load_songs
    @show_play_modal = (params[:dsm].to_s == '1' || (user_signed_in? && (@song.user_id.to_s == current_user.id.to_s))) ? false : true
    respond_to do |format|
      format.html { render :action => :song }
      format.json { render :json => @song }
    end
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
    if @song.destroy
      respond_with :head => :ok
    else
      respond_with(:errors => @model.errors.full_messages, :status => 422)
    end
  end

  def share
    if session[:share_song_id].present?
      params[:message] ||= session[:share_song_message]
      if @song.user.blank? && @song.id.to_s == session[:share_song_id].to_s
        @song.user = current_user 
        @song.save
      end
      session[:share_song_message] = session[:share_song_id] = nil
    end
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
