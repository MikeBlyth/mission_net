ActionMailer::Base.smtp_settings = {
#  :address        => 'gator31.hostgator.com',
#  :port           => '465',
  :address        => 'mail.livinginnigeria.org',
  :port           => '25',
  :authentication => :plain,
  :user_name      => 'joslink+livinginnigeria.org',
  :password       => 'wmbayouessexghettorick5W',
  :domain         => 'joslink.herokuapp.com'
}
ActionMailer::Base.delivery_method = :smtp

#ActionMailer::Base.smtp_settings = {
#  :address              => "smtp.gmail.com",
#  :port                 => 587,
##  :domain               => 'livinginnigeria.org',
#  :user_name            => 'barbblyth@gmail.com',
#  :password             => 'rWEP4A8uth4',
#  :authentication       => 'plain',
#  :enable_starttls_auto => true  }
