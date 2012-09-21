require 'yaml'
module MessagesHelper

  def to_groups_column(record, column)
    return nil if record.to_groups.nil?
    record.to_groups_array.map {|g| Group.find_by_id(g.to_i).to_s}.join(", ")
  end 

  def status_summary_column(record, column)
    status = record.current_status
    I18n.t('message_status_summary', :deliv=>status[:delivered], :pend=>status[:pending], 
        :reply=>status[:replied], :err=>status[:errors])
  end
  
  def body_column(record, column)
#    if record.sms_only && record.sms_only.size > 40
#      record.sms_only
#    else
#      record.body[0..140] if record.body
#    end
simple_format(h(record.body)).gsub("\r\n", "\n").html_safe if record.body
  end

  # Unit in is always hours. Unit out can be hours or minutes
  def time_choices(choices, unit_out=:hour)
    multiplier = case unit_out
      when :hour, :hours then 1
      when :minute, :minutes then 60
      else raise "Invalid time unit specified: #{unit_out}"
    end 
    choice_list = choices.map do |c|
      case 
        when c.kind_of?(Array)   # A choice specified manually
          c
        when c.kind_of?(Integer) && c >= 1 
          [I18n.t(:hour, :count => c), c * multiplier]
        else 
          minutes = (c * 60).to_i
          ["#{minutes} #{I18n.t :minutes}", (c * multiplier).to_i]
      end
    end
  end    

  #  Generate or find the message id tag used to identify confirmation responses
  #  A bit complicated because of using different formats in the subject line and the
  #  message body, and a different format when presenting the message than when confirming it.
  #  Maybe that's totally unnecessary and we can come up with a single style.
  #  If action is :generate, the tag is created (a string)
  #  If action is :find, the tag is searched for; if found, the message number is returned
  #  If action is :confirm_tag, the confirmation form used in body is returned (e.g., '!500' w quotes)
  def message_id_tag(params={:id => 0, :text => nil, :location=>:body, :action=>:generate})
    tag_string = SiteSetting.message_id_string
#puts "**** params=#{params}"
    case params[:action]
    when :generate
      if params[:location] == :body
        return "##{params[:id]}"
      else
        return "(#{tag_string} ##{params[:id]})"
      end
    when :find
      if params[:location] == :body
        params[:text] =~ /[\s\(\[]*!([0-9]+)/ || params[:text] =~ /confirm +[!#]([0-9]+)/i
        return $1 ? $1.to_i : nil
      else
        params[:text] =~ Regexp.new(tag_string + '\s#([0-9]{1,9})\)', true)
        return $1 ? $1.to_i : nil
      end
    when :confirm_tag    # This is for use in an explanation of how to confirm
      return "!#{params[:id]}"
    end
  end

  def find_message_id_tag(params={:subject=>nil, :body=>nil})
    message_id_tag(:action => :find, :text => params[:subject], :location => :subject) ||
    message_id_tag(:action => :find, :text => params[:body], :location => :body) 
  end  
  
  MessageStatuses = {
    -1 => I18n.t( 'msg_status.Error'),
     0 => I18n.t( 'msg_status.Sent'),
     1 => I18n.t( 'msg_status.Pending'),
     2 => I18n.t( 'msg_status.Delivered'),
     3 => I18n.t( 'msg_status.Responded')
     }
    
  MsgError = -1
  MsgSentToGateway = 0
  MsgPending = 1
  MsgDelivered = 2
  MsgResponseReceived = 3
  
  def msg_status_column(record)
    MessageStatuses[record.msg_status]
  end
   
end
