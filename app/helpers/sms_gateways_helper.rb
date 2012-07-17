module SmsGatewaysHelper 
 
  # Default gateway (as a class) used for sending. The class is taken from the string in SiteSetting.gateway_name so
  # the developer or administrator can change it without changing code (as long as the desired gateway class is already
  # written). When not in production, a different class is used which is supposed to be a semi-functional one used for
  # testing. 
  # Thus if the setting string is mysender
  #   in production, a new instance of MysenderGateway is returned
  #   in testing and development, a new instance of MockMysenderGateway is returned if it's a defined class,
  #     otherwise a new instance of MockClickatellGateway is returned
  def default_sms_gateway
    gateway_name = SiteSetting.default_outgoing_sms_gateway
    raise "Trying to send SMS but no gateway defined in site settings" unless gateway_name
    gateway_name = gateway_name.capitalize + "Gateway"
    if Rails.env == 'production'
      return gateway_name.constantize.new
    else    
      ('Mock' + gateway_name).constantize.new rescue MockClickatellGateway.new # i.e. if first doesn't work, use MockClickatellGateway
    end
  end
end   

