class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    if request.env["omniauth.auth"].info.email.blank?
      redirect_to "/users/auth/facebook?auth_type=rerequest&scope=email"
    else
      sign_in_from_omniauth
    end
  end

  private

  def sign_in_from_omniauth
    @user = User.from_oauth(OmniauthWrapper.new(request.env["omniauth.auth"]))

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      set_flash_message(:danger, :failure, kind: "Facebook") if is_navigational_format?
      redirect_to :back
    end
  end
end
