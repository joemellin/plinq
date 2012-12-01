class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me

  ## Database authenticatable
  field :name,               :type => String, :default => ""
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :email
  validates_presence_of :encrypted_password, :if => :password_required?
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  field :admin, :type => Boolean, :default => false
  field :remote_pic_url, :type => String
  field :twitter, :type => String
  field :location, :type => String


  has_many :songs
  has_many :authentications

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  validates_presence_of :name
  validates_uniqueness_of :name, :email, :case_sensitive => false
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  #
  # OMNIAUTH LOGIC
  #
  
  def self.auth_params_from_omniauth(omniauth)
    prms = {:provider => omniauth['provider'], :uid => omniauth['uid']}
    if omniauth['credentials']
      prms[:token] = omniauth['credentials']['token'] if omniauth['credentials']['token']
      prms[:secret] = omniauth['credentials']['secret'] if omniauth['credentials']['secret']
    end
    prms
  end

  def apply_omniauth(omniauth)
    auth = Authentication.new(User.auth_params_from_omniauth(omniauth))
    authentications << auth
    begin
      # TWITTER
      if omniauth['provider'] == 'twitter'
        self.name = omniauth['info']['name'] if name.blank? and !omniauth['info']['name'].blank?
        self.remote_pic_url = omniauth['info']['image'] if !self.pic? && omniauth['info']['image'].present?
        self.location = omniauth['info']['location'] if !omniauth['info']['location'].blank?
        self.twitter = omniauth['info']['nickname']
        #self.followers_count = omniauth['extra']['raw_info']['followers_count'] if omniauth['extra'].present? && omniauth['extra']['raw_info'].present?
      # FACEBOOK
      elsif omniauth['provider'] == 'facebook'
        self.name = omniauth['info']['name'] if name.blank? and !omniauth['info']['name'].blank?
        if self.email.blank?
          self.email = omniauth['extra']['user_hash']['email'] if omniauth['extra'] && omniauth['extra']['user_hash'] && !omniauth['extra']['user_hash']['email'].blank?
          self.email = omniauth['info']['email'] unless omniauth['info']['email'].blank?
        end
        self.email = "#{omniauth['info']['nickname']}@users.facebook.com" if self.email.blank?
        self.location = omniauth['info']['location'] if omniauth['info']['location'].present?
      end
      self.valid?
      logger.info self.errors.full_messages.join(',')
    rescue
      logger.warn "ERROR applying omniauth with data: #{omniauth}"
    end
  end

  def password_required?
    (!password.blank? || authentications.empty?) && super
  end
  
  def uses_password_authentication?
    !self.encrypted_password.blank?
  end
  
   # Returns boolean if user is authenticated with a provider 
   # Parameter: provider_name (string)
  def authenticated_for?(provider_name)
    authentications.where(:provider => provider_name).count > 0
  end
end
