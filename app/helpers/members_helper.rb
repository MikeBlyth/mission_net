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

  def phone_1_column(record, column)
    filter_private_data(record, :phone_1, :phone_private)
  end

  def phone_2_column(record, column)
    filter_private_data(record, :phone_2,  :phone_private)
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
    phones = []
    emails = []
    formatted[:couple]= member.last_name_first(:short=>true, :middle=>false) + (wife ? " & #{wife.short}" : '')
    return formatted unless options[:include_contacts]
    phones[0] = member.phone_private ? '---' : format_phone(member.phone_1) || '---'
    emails[0] = member.email_1 || '---'
    if wife # if there IS a wife
      phones[1] = format_phone(wife.phone_1) if wife.phone_1 &&
          ! wife.phone_private &&
          wife.phone_1 != member.phone_1
      emails[1] = wife.email_1 if wife.email_1 &&
          wife.email_1 != member.email_1
    end
    # Add a second phone & email if they exist and only one has been used already
    phones[1] = format_phone(member.phone_2) if member.phone_2 && phones.length < 2 
    emails[1] = member.email_2 if member.email_2 && emails.length < 2
    formatted[:phones] = phones
    formatted[:emails] = emails
    return formatted
  end

end
