module MembersHelper

  # Needed to suppress the 'Replace with new record' button on edit page
  def column_show_add_new(column, associated, record)
          true 
  end

  # Filters out record[column] when record[privacy_field] is true, unless user is moderator or viewing own record
  def filter_private_data(record, column, privacy_field)
    data = record.attributes[column.to_s]
    if data.blank? || $current_user.roles_include?(:moderator) || !record.attributes[privacy_field.to_s] || $current_user.id == record.id
      data
    else
      t(:private_data)
    end
  end

  def phone_1_column(record)
    filter_private_data(record, :phone_1, :phone_private)
  end

  def phone_2_column(record)
    filter_private_data(record, :phone_2,  :phone_private)
  end

  def email_1_column(record)
    filter_private_data(record, :email_1, :email_private)
  end

  def email_2_column(record)
    filter_private_data(record, :email_2, :email_private)
  end


end
