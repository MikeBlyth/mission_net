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
      puts "#{group.group_name}: #{dups} duplications removed"
    else
      puts "#{group.group_name}: OK"
    end
  end
end

