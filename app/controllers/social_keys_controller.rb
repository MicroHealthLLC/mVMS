class SocialKeysController < BaseController
  before_action  :authenticate_user!
  before_action :intialize_settings, only: :new

  def new

  end

  def create
    ['OFFICE365', 'GOOGLE', 'FACEBOOK', 'LINKEDIN', 'TWITTER'].each do |provider|
      Setting["#{provider}_SECRET"] = params["#{provider.downcase}"]['secret']
      Setting["#{provider}_KEY"] = params["#{provider.downcase}"]['key']
    end

    Devise.setup do |config|
      config.omniauth :linkedin, Setting['LINKEDIN_KEY'], Setting['LINKEDIN_SECRET'], scope: 'user:email'
      config.omniauth :office365, Setting['OFFICE365_KEY'], Setting['OFFICE365_SECRET'], :scope => 'openid profile email https://outlook.office.com/mail.read'
      config.omniauth :facebook, Setting['FACEBOOK_KEY'], Setting['FACEBOOK_SECRET']
      config.omniauth :twitter, Setting['TWITTER_KEY'], Setting['TWITTER_SECRET'], scope: 'user:email'
      config.omniauth :google_oauth2, Setting['GOOGLE_KEY'], Setting['GOOGLE_SECRET']
    end

    flash[:notice] = "keys updated successfully"
    redirect_to new_social_key_path
  end

  def intialize_settings
    if Setting.count == 0
      Setting.create(name: "facebook key",value: '',setting_type: 'FACEBOOK_KEY')
      Setting.create(name: "facebook secret",value: '',setting_type: 'FACEBOOK_SECRET')
      Setting.create(name: "google key",value: '',setting_type: 'GOOGLE_KEY')
      Setting.create(name: "google secret",value: '',setting_type: 'GOOGLE_SECRET')
      Setting.create(name: "office key",value: '',setting_type: 'OFFICE365_KEY')
      Setting.create(name: "office secret",value: '',setting_type: 'OFFICE365_SECRET')
      Setting.create(name: "twitter key",value: '',setting_type: 'TWITTER_KEY')
      Setting.create(name: "twitter secret",value: '',setting_type: 'TWITTER_SECRET')
      Setting.create(name: "linkedin key",value: '',setting_type: 'LINKEDIN_KEY')
      Setting.create(name: "linkedin secret",value: '',setting_type: 'LINKEDIN_SECRET')
    end
  end

end