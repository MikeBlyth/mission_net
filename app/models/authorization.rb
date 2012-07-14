class Authorization < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id
  belongs_to :member
  validates :provider, :uid, :presence => true

  # Return the Authorization record for this user and provider. 
  # If one does not exist, create it. 
  # This method is used when the user has already been authenticated (by whatever provider), hence
  # the auth_hash is passed.
  def self.find_or_create(auth_hash, user)
    unless auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
#      user = User.create :name => auth_hash["info"]["name"], :email => auth_hash["info"]["email"]
      auth = create :member => user, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
    end
    return auth
  end
  
end
