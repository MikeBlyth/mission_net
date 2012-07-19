module GroupsHelper

  # Return a set of choices for select statement used in choosing which groups a member belongs to.
  # * If user is a moderator or administrator, any groups can be selected.
  # * If user is not a moderator or admin, only groups with "user_selectable" can be selected.
  # This lets us have a general groups such as "security alerts" , which the user can select,
  #   while others (e.g. Administrators!) require an authorized person to select.
  def group_choices(member)
    choices = ''
    Group.order('group_name').each do |group|
      selected = member.groups.include?(group) ? " selected='selected'" : ''
      if current_user_moderator? 
        disabled = ''
      else
        disabled = group.user_selectable ? '' : " disabled='disabled'"
      end
      choices << "<option value='#{group.id}'#{selected}#{disabled}>#{group.group_name}</option>"
    end 
    return choices.html_safe
  end 
end
