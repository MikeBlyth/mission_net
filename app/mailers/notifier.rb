class Notifier < ActionMailer::Base
  default :from => SiteSetting.base_email_address
  include ApplicationHelper
  include IncomingMailsHelper  
  include NotifierHelper
  include MessagesHelper
    
# Question: we use something like Notifier.send_help to get a message. This looks like 
# and instance method, so how can we call it for Notifier? Why don't we have to define
# send_help as a class method?

  def send_help(recipients)
    @content = help_content

    mail(:to => recipients, :subject=>I18n.t(:help_subject_line, :site=>SiteSetting.org_system_name)) do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
  end

  # Create messages to each recipient member summarizing their database content.
  # Contents of message is generated by member_summary_content in notifier_helper.rb
  def send_member_summary(member)
  #puts "Processing #{member ? member.name : "NIL"} for summary"
    @content = member_summary_content(member)
    msg = mail(:to => member.primary_email, 
#               :cc => SiteSetting.base_email_address,
               :from => SiteSetting.base_email_address,
               :subject=> I18n.t(:member_summary_subject_line, :site=>SiteSetting.org_system_name)) do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end
  end

  def send_group_message(params) #recipients, content, subject, id, response_time_limit, bcc=false)
    @content = params[:content]
    @id = params[:id]
    @response_time_limit = params[:response_time_limit]
# puts "**** Notifier @response_time_limit=#{@response_time_limit}"
    @subject = params[:subject] + ' ' + message_id_tag(:action=>:generate, :id=>@id)
    @bcc = params[:bcc]
    @following_up = params[:following_up]
    @recipients = params[:recipients].compact
#puts "**** @recipients=#{@recipients}, @subject=#{@subject}"
    mail(
      :to => (@bcc ? '' : @recipients),
      :bcc => (@bcc ? @recipients : ''), 
      :subject => @subject
                          ) do |format|
      format.text {render 'group_message'}
      format.html {render 'group_message'}
    end 
  end

  def send_test(recipients, content)
    @content = "Test from #{SiteSetting.org_system_name}\n\n#{content}"
    mail(:to => recipients, :subject=>'Test from database') do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
  end

  # Version with positional arguments, just wraps the hashed version
  def send_generic(recipients, content, bcc=false)
#puts "**** send_generic recipients=#{recipients}, content=#{content}"
    send_generic_hashed(
      :recipients => recipients,
      :content => content,
      :bcc => bcc)
  end

  def send_generic_hashed(options={})
#puts "**** send_generic_hashed with options=#{options}"
    @content = options[:content] || options[:body] || options[:text]
    bcc = options[:bcc] || false
    recipients = options[:to] || options[:recipients]
    subject = options[:subject] || I18n.t(:generic_subject_line) 
    mail(
      :to => (bcc ? '' : recipients),
      :bcc => (bcc ? recipients : ''), 
      :subject=> subject
                                           ) do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
AppLog.create(:code => 'Email.outgoing', :description => "For #{recipients}, subject=#{subject}", :severity => 'Info')
  end      


#  def send_report(recipients, report_name, report)
#  #puts "Send Report: recipients=#{recipients}, report_name=#{report_name}"
#    @content = "The latest #{report_name} from the #{Settings.site.name} is attached."
#    attachments[report_name] = report
#    mail(:to => recipients, :subject=>"#{report_name} you requested") do |format|
#      format.text {render 'generic'}
#      format.html {render 'generic'}
#    end
#  end    

  # TODO: should be able to use contact.summary here for all the contact info.
  # NEEDS Refactoring in any case
  # Could use one I18n template instead of adding content piecemeal
  def send_info(recipients, from_member, request, members)
    @content = I18n.t('send_info.first_line', :request => request)
    if members.empty?
      @content << I18n.t('send_info.no_contacts')
    else
      members.each do |m|
        self_info = (m == from_member)
        @content << "#{m.name}:\n" 
        @content << I18n.t('send_info.location', :location => m.location) if m.location
        phones = smart_join([format_phone(m.phone_1), format_phone(m.phone_2)])
        emails = smart_join([format_phone(m.email_1), format_phone(m.email_2)])
        @content << I18n.t('send_info.phones', :phones => phones) + "\n" unless phones.blank? || m.phone_private
        @content << I18n.t('send_info.emails', :emails => emails) + "\n" unless emails.blank? || m.email_private
        @content << I18n.t('send_info.phones', :phones => phones) + ' ' +
           I18n.t('send_info.private') + "\n" if self_info && m.phone_private
        @content << I18n.t('send_info.emails', :emails => emails) + ' ' +
           I18n.t('send_info.private') + "\n" if self_info && m.email_private
        @content << "\n"
        if self_info && (m.phone_private || m.email_private)
          @content << I18n.t('send_info.privacy_note')
        end
      end
    end
    mail(:to => recipients, :subject=> I18n.t(:info_request_subject_line)) do |format|
      format.text {render 'generic'}
      format.html {render 'generic'}
    end 
  end

  def contact_updates(recipients, contacts)
    @contacts = contacts
    @email = true # Same template used for screen display (check) & actual mailing, so @email is
                  # used to flag that we are emailing msg. So we don't include the "Send" button.
    mail(:to => recipients, :subject=>'Recently updated contact info') do |format|
      format.text {render 'reports/contact_updates'}
      format.html {render 'reports/contact_updates'}
    end 
  end

end
