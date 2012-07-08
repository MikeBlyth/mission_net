module GroupsHelper

  def members_column(record)
    record.members.map{|m| m.full_name_short}.join('; ')
  end

  def to_s
    abbrev
  end

end
