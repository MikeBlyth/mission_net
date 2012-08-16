class MembersController < ApplicationController
  helper :countries

  include ApplicationHelper

  skip_before_filter :authorize_privilege
  load_and_authorize_resource

  # CONFIGURE ACTIVE SCAFFOLD FOR THIS TABLE
  ListColumnsFull = [:name, :last_name, :first_name, :middle_name, :short_name, :country,
        :phone_1, :phone_2, :phone_private, :email_1, :email_2, :email_private, 
        :location, :location_detail, :in_country, :comments,
        :arrival_date, :departure_date, :groups, :blood_donor, :bloodtype]
  ListColumnsCompact = [:name, 
        :phone_1, :phone_2, :email_1, 
        :location, :location_detail, :in_country, :comments,
        :arrival_date, :departure_date]

  active_scaffold :member do |config|
    config.label = "Members"  # Main title
    # Columns that appear in the list view. This also determines their order across the page.
#    list_columns = [:name, :last_name, :first_name, :middle_name, :short_name, :country,
#        :phone_1, :phone_2, :phone_private, :email_1, :email_2, :email_private, 
#        :location, :location_detail, :in_country, :comments,
#        :arrival_date, :departure_date, :groups, :blood_donor, :bloodtype]
    list.columns = ListColumnsFull

    # Set default sorting
    config.columns[:name].sort_by :sql
    config.list.sorting = {:name => 'ASC'}

    # These columns will be shown in the other views. Less important since
    # these views are probably all overriden anyway.
#    create.columns = show.columns = update.columns = [:name, 
#          :last_name, :first_name, :middle_name,
#          :country,
#        :phone_1, :phone_2, :email_1, :email_2, 
#        :location, :location_detail, 
#        :arrival_date, 
#        :departure_date, 
#        :groups,
#        :emergency_contact_phone, :emergency_contact_email, :emergency_contact_name,
#        :blood_donor, :bloodtype,
#          ]
    config.columns[:country].actions_for_association_links = []  # Don't show link to country record
    config.columns[:country].form_ui = :select 
    config.columns[:location].form_ui = :select 
    config.columns[:bloodtype].form_ui = :select 
    
    # Any columns that should not be shown as links in the list view
    config.columns[:groups].clear_link
        
    # Default is to allow in place editing of all list columns. Exclude any in next line
    exclude_from_inplace_edit = []  # add any columns that should not be editable on the list view
#binding.pry  
    (ListColumnsFull-exclude_from_inplace_edit).each {|col| config.columns[col].inplace_edit = true}

#    # These columns will be hidden in the compact view
#    compact_view_columns = [:last_name, :first_name, :middle_name, :short_name, :country, :email_2, :email_private, :location_detail, 
#       :blood_donor, :bloodtype]
#    compact_view_columns.each {|col| config.columns[col].css_class = 'hideable'}
    
    # Use the field search instead of the undifferentiated search
    config.actions.exclude :search
    config.actions.add :field_search
    config.field_search.human_conditions = true
    config.field_search.columns = [:last_name, :groups, :location, :phone_1, :bloodtype, :blood_donor]

    # Add the export link to top of page
    config.action_links.add 'export', :label => 'Export', :page => true, :type => :collection, 
     :confirm=>'This will download all the member data (most fields) for ' + 
       'use in your own spreadsheet or database, and may take a minute or two. Is this what you want to do?'

    # Any links that should open in their own page rather than inline with JS/Ajax
    config.update.link.page = true # At present, the jQuery multiselect widget doesn't work when edit is done inline

  end

  def index
    @notices = "Bug fixed. Hiding/showing columns should be stable now. Please make a note if there are still problems."
#    session[:compact] = true if session[:compact].nil?   # Start with compact view. Make false to start with full view
    @compact = params[:compact]
    session[:compact] = @compact
    active_scaffold_config.list.columns = @compact ? ListColumnsCompact : ListColumnsFull
#binding.pry  
    super
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
#puts "****in update, current_user=#{current_user.id}, role=#{current_user.role}"
    unless current_user.role == :administrator
      merged = merge_group_ids
#puts "**** merged=#{merged}"
      params[:record][:groups] = merge_group_ids if merged.any?
    end
    super
#puts "****after update, current_user=#{current_user.id}, role=#{current_user.role}, groups=#{current_user.groups}"
#puts "**** params[:record][:short_name]=#{params[:record][:short_name]}, record has #{@record.reload.short_name}"
#    rec_params = params[:record]
#    @record.update_attributes(:short_name => rec_params[:short_name], # For some reason it won't update :short_name!
#      :in_country => rec_params[:in_country], 
#      :phone_private => rec_params[:phone_private], 
#      :comments => rec_params[:comments],
#      :email_private => rec_params[:email_private])
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
  
