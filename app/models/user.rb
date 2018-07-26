class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  ApplicationRecord.all
  attr_accessor :remember_token, :activation_token 
  before_create :create_activation_digest
  before_save { email.downcase! }
  validates :name, presence: true
  validates :email, presence: true,
    format: { with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false}
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  has_secure_password

  def authenticated?(attribute, token)
    token_digest = send("#{attribute}_digest")
    return false if token_digest.nil?
    BCrypt::Password.new(token_digest).is_password?(token)
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def send_activation_email
      UserMailer.account_activation(self).deliver_now
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  private
    def create_activation_digest
     self.activation_token  = User.new_token
     self.activation_digest = User.digest(activation_token)
    end

end
