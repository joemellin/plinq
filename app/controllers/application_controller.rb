class ApplicationController < ActionController::Base
  protect_from_forgery

  # User will always be able to see their account so redirect them here
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to (user_signed_in? ? current_user : '/'), :alert => exception.message
  end

  def capture_and_login
    session[:password_not_required] = true
    session[:redirect_to] = params[:redirect_to]
    redirect_to '/auth/facebook'
  end

  protected

  def after_sign_in_path_for(resource_or_scope)
    if session[:share_song_id].present?
      share_song_path(:id => session[:share_song_id])
    else
      root_path
    end
  end

  def load_songs
    @show_play_modal = false
    @songs = Song.featured.asc(:created_at).limit(20)
    @play_count = @songs.inject(0){|r, e| r += e.play_count; r}
  end

  def login_required
    if user_signed_in?
      return true
    else
      if params[:message].present?
        session[:share_song_id] = params[:id]
        session[:share_song_message] = params[:message]
      end
      redirect_to '/auth/facebook'
      return false
    end
  end

  def admin_required
    if login_required
      if current_user.admin?
        return true
      else
        flash[:notice] = "You don't have admin access"
        redirect_to '/'
      end
    end
    return false
  end
end
