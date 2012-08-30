module MembersHelper

  # Needed to suppress the 'Replace with new record' button on edit page
  def column_show_add_new(column, associated, record)
          true 
  end

  # Filters out record[column] when record[privacy_field] is true, unless user is moderator or viewing own record
  def filter_private_data(record, column, privacy_field)
    data = record.attributes[column.to_s]
    if data.blank? || current_user.roles_include?(:moderator) || !record.attributes[privacy_field.to_s] || current_user.id == record.id
      data
    else
      t(:private_data)
    end
  end

  def can_edit_member(member, user)
    user.roles_include?(:moderator) ||
    member.id == user.id ||
    member.wife_id == user.id ||
    (member.husband && member.husband.id == user.id)
  end
  
  def wife_column(record, column)
    record.wife ? record.wife.short : nil
  end

  def phone_1_column(record, column)
    filtered = filter_private_data(record, :phone_1, :phone_private)
    filtered == t(:private_data) ? filtered : format_phone(filtered, :delim_1 => "\u00a0", :delim_2 => "\u00a0")
  end

  def phone_2_column(record, column)
    filtered = filter_private_data(record, :phone_2, :phone_private)
    filtered == t(:private_data) ? filtered : format_phone(filtered, :delim_1 => "\u00a0", :delim_2 => "\u00a0")
  end

  def email_1_column(record, column)
    filter_private_data(record, :email_1, :email_private)
  end

  def email_2_column(record, column)
    filter_private_data(record, :email_2, :email_private)
  end

  def options_for_association_conditions(association)
    if association.name == :wife
      'false'
    else
      super
    end
  end

  # Returns family data in a formatted hash like
  # :couple => 'Blyth, Mike & Barb', :phone=> '0803-555-5555\n0803-666-6666',
  #   :email => 'mike.blyth@sim.org\nmjblyth@gmail.com'.
  # Private data will be masked unless show_private is true
  # 
  def family_data_formatted(member, options={:show_private=>false, :include_contacts=>true})
    formatted = {}
    wife = member.wife
    emails = []
    member_name = member.last_name_first(:short=>true, :middle=>false)
    wife_name = wife ? " & #{wife.short}" : ''
    formatted[:couple]= member_name + wife_name
    if member.in_country 
      away_string = ''
    else
      away_string = "*"
      away_string << " (return ~ #{member.arrival_date})" if 
            (member.arrival_date && member.arrival_date >= Date.today)
    end
    formatted[:couple_w_status] = member_name + wife_name + away_string
    return formatted unless options[:include_contacts]
    emails[0] = member.email_1 || '---'
    if wife # if there IS a wife
      emails[1] = wife.email_1 if wife.email_1 &&
          wife.email_1 != member.email_1
    end
    # Add a second phone & email if they exist and only one has been used already
    emails[1] = member.email_2 if member.email_2 && emails.length < 2
    formatted[:phones] = phone_string_couple(member)
    formatted[:emails] = emails
    return formatted
  end

private

  def person_has_phone?(member, phone)
    (member.phone_1 == phone || member.phone_2 == phone) ||
    (member.phone_private && phone == I18n.t(:private_dir))
  end

  def phone_string_couple(member, options={})
    private_string = I18n.t(:private_dir)
    wife = member.wife
    if wife.nil?
      return [private_string] if member.phone_private
      return [format_phone(member.phone_1), format_phone(member.phone_2)].not_blank!
    end
    all_phones = member.phone_private ? [private_string] : [member.phone_1, member.phone_2]
    all_phones += (wife.phone_private  ? [private_string] : [wife.phone_1, wife.phone_2])
    formatted = all_phones.not_blank!.uniq.map do |p|
      whose_phone = case
        when person_has_phone?(member, p) && person_has_phone?(wife, p)
          I18n.t(:both_have_phone)
        when person_has_phone?(member, p)
          "(#{member.short})"
        when person_has_phone?(wife, p)
          "(#{wife.short})"
      end
      format_phone(p) + ' ' + whose_phone
    end
    return formatted
  end # phone_string_couple
end
