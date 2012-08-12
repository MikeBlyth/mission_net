class MembersController < ApplicationController
  helper :countries

  include ApplicationHelper

  skip_before_filter :authorize_privilege
  load_and_authorize_resource

  active_scaffold :member do |config|
    # Enable user-configurable listing (user can select and order columns)

    config.label = "Members"
    list_columns = [:name, :last_name, :first_name, :middle_name, :short_name, :country,
        :phone_1, :phone_2, :phone_private, 
        :email_1, :email_2, :email_private, 
        :location, :location_detail, 
        :in_country, :comments,
        :arrival_date, :departure_date, :groups, :blood_donor, :bloodtype]
#    config.actions << :config_list
#    config.config_list.default_columns = [:name, :country, :phone_1, :email_1, :location, :arrival_date, :departure_date] 
    list.columns = list_columns
    config.columns[:name].sort_by :sql
    config.list.sorting = {:name => 'ASC'}
    create.columns = show.columns = update.columns = [:name, 
          :last_name, :first_name, :middle_name,
          :country,
        :phone_1, :phone_2, :email_1, :email_2, 
        :location, :location_detail, 
        :arrival_date, 
        :departure_date, 
        :groups,
        :emergency_contact_phone, :emergency_contact_email, :emergency_contact_name,
        :blood_donor, :bloodtype,
          ]
    config.columns[:country].actions_for_association_links = []
    config.columns[:groups].clear_link
    config.columns[:country].inplace_edit = true
    config.columns[:country].form_ui = :select 
    config.columns[:in_country].inplace_edit = true
    config.columns[:name].inplace_edit = true
    config.columns[:last_name].inplace_edit = true
    config.columns[:first_name].inplace_edit = true
    config.columns[:middle_name].inplace_edit = true
    config.columns[:short_name].inplace_edit = true
    config.columns[:phone_1].inplace_edit = true
    config.columns[:email_1].inplace_edit = true
    config.columns[:phone_2].inplace_edit = true
    config.columns[:email_2].inplace_edit = true
    config.columns[:phone_private].inplace_edit = true
    config.columns[:email_private].inplace_edit = true
    config.columns[:emergency_contact_phone].inplace_edit = true
    config.columns[:emergency_contact_email].inplace_edit = true
    config.columns[:emergency_contact_name].inplace_edit = true
    config.columns[:arrival_date].inplace_edit = true
    config.columns[:departure_date].inplace_edit = true
    config.columns[:location].inplace_edit = true
    config.columns[:location].form_ui = :select 
    config.columns[:location_detail].inplace_edit = true
    config.columns[:bloodtype].inplace_edit = true
    config.columns[:bloodtype].form_ui = :select 
    config.columns[:blood_donor].inplace_edit = true
    config.columns[:comments].inplace_edit = true
    
   config.actions.exclude :search
   config.actions.add :field_search
   config.field_search.human_conditions = true
   config.field_search.columns = [:last_name, :groups, :location, :phone_1, :bloodtype, :blood_donor]
   config.action_links.add 'export', :label => 'Export', :page => true, :type => :collection, 
     :confirm=>'This will download all the member data (most fields) for ' + 
       'use in your own spreadsheet or database, and may take a minute or two. Is this what you want to do?'
   config.update.link.page = true # At present, the jQuery multiselect widget doesn't work when edit is done inline
#   config.update.link.security_method = :display_edit_link
  end

  # Given params hash, change :something_id to :something
  def convert_keys_to_id(params, *keys_to_change)
    return params if keys_to_change.nil? || params.nil?
    keys_to_change.each do |k|
      v = params.delete(k)
      params[(k.to_s << '_id').to_sym] = v unless v.blank?  # resinsert value but with _id added to key
    end
    params
  end

#   Export CSV file. Exports ALL records, so will have to be modified if a subset is desired
#   No params currently in effect
  def export(params={})
     columns = delimited_string_to_array(Settings.export.member_fields)
     columns = ['name'] if columns.empty?  # to prevent any bad behavior with empty criteria
     send_data Member.export(columns), :filename => "members.csv"
  end

  def import(options={})
    if request.post? && params[:file].present? 
      infile = params[:file].read 
      n, errs = 0, [] 
      alerts_group = Group.find_by_group_name('Security alerts')
      alerts_group = Group.find_or_create_by_group_name(:group_name => 'Security alerts',
          :abbrev => 'alerts', 
          :parent_group => Group.find_by_group_name('All'))
      security_group = Group.find_or_create_by_group_name(:group_name => 'Security leaders', 
          :abbrev => 'sec', 
          :parent_group => Group.find_by_group_name('All'))
      CSV.parse(infile, :headers=>true, :header_converters=>:symbol, :converters => :all) do |row| 
        if row[:name] =~ /\A(.*),\s*(.*)/
          first_name = $2
          last_name = $1
        elsif row[:name] =~ /\A(.*)\s*(\S+)/
          last_name = $2
          first_name = $1
        end
        member = Member.create!(:name=>row[:name], :last_name=>last_name, :first_name=>first_name,
             :phone_1 => row[:phone_1], :phone_2 => row[:phone_2], :email_1 => row[:email_1],
             :in_country => row[:in_country] == 'true',
             :comments => row[:comments])
        member.groups << [alerts_group] if row[:groups] =~ /(General security)|JosTwitr/
        member.groups << security_group if row[:groups] =~ /Security leaders/i
      end
    end
    redirect_to members_path if request.post?  # Finished with importing, so go to members list
  end
   
  def set_full_names
    Member.find(:all).each do |m| 
      if m.name.blank? || (m.first_name == m.short_name)
        m.update_attributes(:name => m.indexed_name)
      end
      m.name = m.name.strip if m.name[-1]= ' '
    end
    redirect_to(:action => :index)
  end

  def do_edit
    super
    case current_user.role
    when :administrator
      @selectable = 'true'
    when :moderator
      @selectable = "administrator = 'f' OR administrator IS NULL"
    else
      @selectable = 'user_selectable'
    end
  end

  def update
#puts "**** params=#{params}"
    unless current_user.role == :administrator
      merged = merge_group_ids
#puts "**** merged=#{merged}"
      params[:record][:groups] = merge_group_ids if merged.any?
    end
    super
#puts "**** params[:record][:short_name]=#{params[:record][:short_name]}, record has #{@record.reload.short_name}"
@record.update_attributes(:short_name => params[:record][:short_name]) # For some reason it won't update :short_name!
@record.update_attributes(:in_country => params[:record][:in_country]) # For some reason it won't update :short_name!
@record.update_attributes(:phone_private => params[:record][:phone_private]) # For some reason it won't update :short_name!
@record.update_attributes(:email_private => params[:record][:email_private]) # For some reason it won't update :short_name!
#puts "**** params[:record][:short_name]=#{params[:record][:short_name]}, after manual update record has #{@record.reload.short_name}"
  end

  # Given (a) the incoming group_ids from the form (params[:record][:groups]), and
  #       (b) the existing group_ids of the record (original_groups)
  #       (c) the set of which groups are changeable for this user (selectable)
  # return the set of group_ids as they should be after the update.
  # 
  def merge_group_ids(params=params, selectable=nil)
    if current_user.role == :moderator
      selectable ||= Group.where("administrator = ? OR administrator IS ?", false, nil).map {|g| g.id.to_s}
    else
      selectable ||= Group.where("user_selectable").map {|g| g.id.to_s}
    end
    original_groups = Member.find(params[:id]).groups.map {|g| g.id.to_s}
    unchangeable = original_groups.map{|g| g.to_s unless selectable.include? g.to_s}
    updates = params[:record][:groups] || []
    valid_updates = updates & selectable
    return (unchangeable + valid_updates).compact
  end

protected
# Need to figure out how this works -- doesn't work as below! 
#  def update_authorized?(record=nil)
#    is_member = (record.is_a? Member)
#    same_id = is_member ? current_user.id == record.id : false
#    ok = is_member && same_id
#    puts "**** record=#{record}, #{record.id if record.is_a? Member}, ok = #{ok}, same-#{same_id}"
#    return ok #|| !is_member
#  end
 
  def display_edit_link(record=nil)
puts "**** moderator = #{current_user.role_include?(:moderator)}"
    return true if current_user.role_include?(:moderator)
    is_member_record = (record.is_a? Member)  # because record parameter can be other than the actual record being edited
    same_id = is_member_record ? current_user.id == record.id : false
    ok = is_member_record && same_id
    puts "**** record=#{record}, #{record.id if record.is_a? Member}, ok = #{ok}, same-#{same_id}"
    return ok #|| !is_member
  end
    
     

end
  
