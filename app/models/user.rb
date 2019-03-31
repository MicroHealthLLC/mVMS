# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  full_name              :string(255)      default("")
#  admin                  :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  avatar                 :string(255)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook, :linkedin, :twitter, :google_oauth2,:office365]
       
  def self.from_omniauth(auth)
    if where(email: auth.info.email || "#{auth.uid}@#{auth.provider}.com").present?
      return where(email: auth.info.email || "#{auth.uid}@#{auth.provider}.com").first
    end
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email || "#{auth.uid}@#{auth.provider}.com"
      user.password = Devise.friendly_token[0,20]
    end
  end
  
  def self.get_user(auth)
    unscoped.where(provider: auth.provider, uid: auth.uid,admin: true).or(User.unscoped.where(email: auth.info.email || "#{auth.uid}@#{auth.provider}.com",admin: true)).first
  end

  def self.current=(user)
    RequestStore.store[:current_user] = user
  end

  def self.current
    RequestStore.store[:current_user] ||= User.new
  end

  def profile_image
    if avatar.thumb.url
      avatar.thumb.url
    else
      'male.png'
    end
  end

  def self.safe_attributes
    [:full_name, :state, :email, :role_id, :time_zone,:password_confirmation,  :password,:admin]
  end

  def name; full_name; end


  mount_uploader :avatar, AvatarUploader
end
