desc "Remove any duplications of the groups-members relationship"
task :unduplicate_group_members => :environment do
  Group.all.each do |group|
    members = group.members.clone
    original_count = members.count
    members.uniq!
    dups = original_count - members.count
    if dups > 0
      Group.transaction do 
        group.members = []
        group.members = members
      end
      puts "Group #{group.group_name}: #{dups} duplications removed"
    else
      puts "Group #{group.group_name}: OK"
    end
  end
  Member.all.each do |member|
    groups = member.groups.clone
    original_count = groups.count
    groups.uniq!
    dups = original_count - groups.count
    if dups > 0
      Member.transaction do 
        member.groups = []
        member.groups = groups
      end
      puts "#{member.name}: #{dups} duplications removed"
    else
      puts "#{member.name}: OK"
    end
  end

end

