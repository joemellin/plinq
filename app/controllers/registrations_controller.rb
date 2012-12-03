class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    super
    session[:omniauth] = session[:password_not_required] = nil unless @user.new_record?
  end

  def edit
    redirect_to edit_user_path(current_user)
  end
  
  private

  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
      @omniauth = true
    end
    @password_not_required = session[:password_not_required]
  end
end