module GroupsHelper

  def group_choices(member)
    # Which groups are *shown* in the list depends on whether the *user* (not member being edited) is a moderator
    select_filter = current_user_moderator? ? 'true' : {:user_selectable => true}
    choices = ''
    Group.where(select_filter).order('group_name').each do |group|
      selected = member.groups.include?(group) ? "selected='selected'" : ''
      choices << "<option value='#{group.id}' #{selected}>#{group.group_name}</option>"
    end 
    return choices.html_safe
  end 
end
