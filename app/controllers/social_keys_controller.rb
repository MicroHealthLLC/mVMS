class SocialKeysController < BaseController
  before_action  :authenticate_user!
  def new

  end

  def create
    ['OFFICE365', 'GOOGLE', 'FACEBOOK', 'LINKEDIN', 'TWITTER'].each do |provider|
      Setting["#{provider}_SECRET"] = params["#{provider.downcase}"]['secret']
      Setting["#{provider}_KEY"] = params["#{provider.downcase}"]['key']
    end
    flash[:notice] = "keys updated successfully"
    redirect_to new_social_key_path
  end
end