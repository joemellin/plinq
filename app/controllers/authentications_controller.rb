class AuthenticationsController < ApplicationController
  include Devise::Controllers::Rememberable # included to set cookie manually
  load_and_authorize_resource :only => [:index, :destroy]

  def index
    redirect_to user_signed_in? ? current_user : '/'
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
    if authentication
      authentication.update_attributes(:token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret']) if omniauth['credentials'] && !omniauth['credentials']['token'].blank?
      remember_me(authentication.user) # set remember me cookie
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user # already a signed in user
      current_user.apply_omniauth(omniauth)
      #current_user.geocode_from_ip(request.remote_ip) if current_user.location.blank?
      if current_user.save
        #flash[:notice] = "#{omniauth['provider']} authentication successful."
      else
        flash[:alert] = "Sorry but you could't be authenticated. Please try again:"
      end
      redirect_to current_user
    else
      user = User.new
      user.apply_omniauth(omniauth)
      user.email = "#{user.twitter}@users.plinq.com" if omniauth['provider'] == 'twitter'
      if user.save
        remember_me(user) # set remember me cookie
        sign_in_and_redirect(:user, user)
      else
        logger.info user.errors.full_messages.join(', ')
        # Extra details are too much to store
        omniauth.delete('extra')
        session[:omniauth] = omniauth
        redirect_to new_user_registration_url
      end
    end
  end
  
  def failure
    flash[:alert] = "Sorry but you could't be authenticated. Please try again:"
    redirect_to new_user_registration_url
  end

  def destroy
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end

  protected

  # This is necessary since Rails 3.0.4
  # See https://github.com/intridea/omniauth/issues/185
  # and http://www.arailsdemo.com/posts/44
  def handle_unverified_request
    true
  end
end
