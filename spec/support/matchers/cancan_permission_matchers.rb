require "cancan/matchers"

# Example (from https://github.com/dchelimsky/rspec/wiki/custom-matchers)
#RSpec::Matchers.define :be_a_multiple_of do |expected|
#  match do |actual|
#    actual % expected == 0
#  end

#  failure_message_for_should do |actual|
#    "expected that #{actual} would be a precise multiple of #{expected}"
#  end

#  failure_message_for_should_not do |actual|
#    "expected that #{actual} would not be a precise multiple of #{expected}"
#  end

#  description do
#    "be a precise multiple of #{expected}"
#  end
#end
puts "LOADING CUSTOM MATCHERS"

RSpec::Matchers.define :be_allowed_to do |expected_abilities|

  match do |role|
#def can(role, abilities)
    success = true
    @unwanted_abilities = []
    @missing_abilities = []
    controller.class.to_s =~ /\A[A-Z][a-z]+/
    @object_klass = $&.singularize.constantize 
    object = @object_klass.new
    user = mock("User", :role => role, :id => 999).as_null_object
    filter = Ability.new(user)
    [:create, :read, :update, :destroy].each do |ability|
      if expected_abilities.include? ability
        unless filter.can?(ability, object)
          success = false
          @missing_abilities << ability
        end
      else
        if filter.can?(ability, object)
          success = false
          @unwanted_abilities << ability
        end
      end
    end
    success
  end

  failure_message_for_should do |actual|
    msg = []
    if @missing_abilities.any?
      missing_string = smart_join(@missing_abilities.map {|a| a.to_s}, ', ', 'and')
      msg << "#{actual} should be allowed to #{missing_string} #{@object_klass} but was not allowed"
    end
    if @unwanted_abilities.any?
      unwanted_string = smart_join(@unwanted_abilities.map {|a| a.to_s}, ', ', 'or')
      msg << "#{actual} should be not allowed to #{unwanted_string} #{@object_klass} but *was* allowed"
    end
    msg.join("\n")
  end

end

