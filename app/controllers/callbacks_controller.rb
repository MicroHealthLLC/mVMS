class CallbacksController < Devise::OmniauthCallbacksController
  
  def office365
    check_omniauth_auth
  end

  def facebook
    check_omniauth_auth
  end

  def twitter
    check_omniauth_auth
  end

  def github
    check_omniauth_auth
  end

  def google_oauth2
    check_omniauth_auth
  end
  
  def linkedin
    check_omniauth_auth
  end

  private

  def check_omniauth_auth
    # if User.get_user(request.env["omniauth.auth"]).nil?
    #   flash[:error] = 'Social Sign up is not enabled'
    #   redirect_to root_path
    # else
      @user = User.from_omniauth(request.env["omniauth.auth"])
      sign_in @user
      flash[:notice] = 'Logged in successfully.'
      redirect_to "/admin"
    end
  # end
end
