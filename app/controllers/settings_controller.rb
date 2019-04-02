class SettingsController < BaseController
  before_action  :authenticate_user!

  def index
    @setting = Setting.first || Setting.new
    @admin_theme_setting = Setting.admin
    @client_theme_setting = Setting.client
  end

  def authentication
    if request.post?
      Setting['whitelist_ip'] = params['whitelist_ip']
      Setting['blacklist_ip'] = params['blacklist_ip']
      Setting['user_default_state'] = params['user_default_state']
      Setting['remember_for'] = params['remember_for']
      Setting['timeout_in'] = params['timeout_in']
      Setting['maximum_attempts'] = params['maximum_attempts']
      Setting['unlock_in'] = params['unlock_in']
      Setting['expire_after'] = params['expire_after']
      Devise.setup do |config|
        config.remember_for = Setting['remember_for'].to_i.weeks
        config.timeout_in = Setting['timeout_in'].to_i.minutes
        config.maximum_attempts = Setting['maximum_attempts'].to_i
        config.unlock_in = Setting['unlock_in'].to_i.hour
        config.expire_after  = Setting['expire_after'].to_i.days
      end
    end

  end
end
