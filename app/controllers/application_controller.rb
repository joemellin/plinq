class ApplicationController < ActionController::Base
  protect_from_forgery

  # User will always be able to see their account so redirect them here
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to (user_signed_in? ? current_user : '/'), :alert => exception.message
  end

  protected

  def load_songs
    @songs = Song.featured.asc(:created_at).limit(20)
  end

  def login_required
    if user_signed_in?
      return true
    else

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
