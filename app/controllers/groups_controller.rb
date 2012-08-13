class GroupsController < ApplicationController
#  before_filter :authenticate #, :only => [:edit, :update]
  include ApplicationHelper
  include SessionsHelper
  include BasePermissionsHelper

  active_scaffold :group do |config|
    # list.columns.exclude :abo, :rh, :members
    config.columns = [:group_name, :abbrev, :primary, :user_selectable, 
      :administrator, :moderator, :member, :limited, :group_member_names,  :parent_group, :subgroups]
    list.sorting = {:group_name => 'ASC'}
    config.show.link = false
#    config.create.link = false
    config.columns[:group_name].inplace_edit = true
    config.columns[:user_selectable].inplace_edit = true
    config.columns[:abbrev].inplace_edit = true
    config.columns[:primary].inplace_edit = true
    config.columns[:administrator].inplace_edit = true
    config.columns[:administrator].label = 'Admin'
    config.columns[:moderator].inplace_edit = true
    config.columns[:member].inplace_edit = true
    config.columns[:limited].inplace_edit = true
    config.columns[:parent_group].inplace_edit = true
    config.columns[:parent_group].form_ui = :select 
    config.action_links.add 'export', :label => 'Export', :page => true, :type => :collection, 
       :confirm=>'This will download all the Groups data (most fields) for ' + 
         'use in your own spreadsheet or database, and may take a minute or two. Is this what you want to do?'
    config.update.link.page = true  # At present, the jQuery multiselect widget doesn't work when edit is done inline
  end

  def attach_group_members
    @record.update_attributes(:member_ids=>params[:record][:member_ids])
  end
  
  def member_count
    groups = params[:to_groups]
    if groups
      target_groups = groups.map {|g| g.to_i}
      count = Group.members_in_multiple_groups(target_groups).count
    else
      count = 0
    end
    @json_resp =  Member.new(:name=>'Jane')
    @json_resp = count # {:member=>'John'}
    respond_to do |format|
      format.js { render :json => @json_resp }
    end
  end    
    
  def do_create
    super
    # For some reason, ActiveScaffold is not updating the parent_group_id, so
    # rather than debug that issue, we're setting it here.
params[:subgroups] = nil  # Hack
    @record.parent_group_id = params[:record][:parent_group_id]
    attach_group_members
  end

#def update
#  puts "update called with params #{params}"
#  record = Group.find params[:id]
#  record.update_attributes params
#end

  def do_update
#puts "**** params=#{params}"
    super
    # For some reason, ActiveScaffold is not updating the parent_group_id, so
    # rather than debug that issue, we're setting it here.
    @record.parent_group_id = params[:record][:parent_group_id]
    attach_group_members
  end

  def export(params={})
     columns = delimited_string_to_array(Settings.export.group_fields)
     send_data Group.export(columns), :filename => "groups.csv"
  end

  def list_authorized2?
    current_user.roles_include?(:member)
  end

end
