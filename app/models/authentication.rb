class Authentication
  include Mongoid::Document
  field :provider, :type => String
  field :uid, :type => String
  field :token, :type => String
  field :secret, :type => String

  belongs_to :user

  attr_accessible :provider, :uid, :token, :secret

  scope :provider, lambda{ |prov| where(:provider => prov) }
  scope :ordered, asc(:created_at)
  
  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end
end
