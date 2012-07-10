#require Rails.root.join('spec/factories')
#require Rails.root.join('spec/spec_helper')
puts "**** INCLUDING SIMTESTHELPER ***"
module SimTestHelper

  def regexcape(s)
    Regexp.new(Regexp.escape(s))
  end

  # 
  def pdf_string_to_text_string(pdf_string)
    temp_pdf = Tempfile.new('pdf')
    temp_pdf << pdf_string.force_encoding('UTF-8')
    temp_pdf.close
    `pdftotext -enc UTF-8 -q #{temp_pdf.path} - 2>&1`
  end

  # Given that the page.body actually contains PDF, convert it to text (keeping it in page.body)
  def pdf_to_text
    page.driver.instance_variable_set('@body', pdf_string_to_text_string(page.body) )
  end

  def create_one_unspecified_code(type, params={})
    type = type.to_s.camelcase.constantize if type.class == Symbol
    unless type.find_by_id(UNSPECIFIED)
      s = type.new(params)
      s.description ||= "Unspecified" if s.respond_to? :description
      s.full ||= "Unspecified" if s.respond_to? :full
      s.code ||= "999999" if s.respond_to? :code
      s.country = "Unspecified" if s.respond_to? :country and !params[:country]
      s.name ||= "Unspecified" if s.respond_to? :name
      s.id = UNSPECIFIED
      s.save
      puts "Errors saving #{type} unspecified: #{s.errors}" if s.errors.length > 0
    end
#puts "create_one_unspec... #{type} #{s}"
  return s
  end    
    
  def create_unspecified_codes
    create_one_unspecified_code(Status)
    create_one_unspecified_code(Ministry)
    create_one_unspecified_code(Country)
    create_one_unspecified_code(City)
    create_one_unspecified_code(Location)
    create_one_unspecified_code(Education)
    create_one_unspecified_code(EmploymentStatus)
    create_one_unspecified_code(Bloodtype)
    create_one_unspecified_code(ContactType)
  end  
    
  def create_spouse(member)
    spouse = Factory(:member, :spouse=>member, :last_name=> member.last_name, 
          :first_name=> "Honey", :family=>member.family, :sex=>member.other_sex, :child=>false,
          :country=>member.country )
    spouse.personnel_data.update_attribute(:employment_status, member.employment_status)
    member.update_attribute(:spouse, spouse)
    puts "Error creating/saving spouse (sim_test_helper ~40)" unless spouse.valid? && member.valid?
    return spouse
  end
  
  def build_spouse(member)
    spouse = Factory.build(:member, :spouse=>member, :last_name=> member.last_name, 
          :first_name=> "Honey", :family=>member.family, :sex=>member.other_sex, :child=>false,
          :country=>member.country )
    spouse.personnel_data = PersonnelData.new(:employment_status=>member.employment_status, :member=>spouse)
    member.spouse = spouse
    puts "Error creating/saving spouse (sim_test_helper ~40)" unless spouse.valid? && member.valid?
    return spouse
  end
  
  def create_couple(f=nil)
    family ||= Factory(:family)
    husband = Factory(:member, :family=>family)
    family.update_attribute(:head, husband)
    wife = create_spouse(husband)
    return husband
  end

  # Given a record with an attribute (like status_id) that might not reflect an existing attribute record
  # since we haven't created it yet, 
  # * Do nothing if it's already created
  # * Create the record if it doesn't already exist, if the create option is true
  # * Return a valid id to insert into the record being created 
  # * Raise an exception if (record doesn't exist and is not to be created) or (unable to create the record)
  def create_associated_details(attribute, attribute_id, create=false)
    attribute_model = attribute.to_s.camelize.constantize  # e.g. Status or PersonnelData
    return attribute_id if attribute_model.find_by_id(attribute_id)   # Corresponding detail record found, return id
   # raise error if there is no corresponding detail record and one is not to be created
    raise "Unable to create needed #{attribute}=#{attribute_id},   \n" +
      "\t(specify true for create option if you want to create automatically). (create_associated_details)." unless create
    # if the attribute id is nil, e.g. :status=>nil, use first existing record if there is one 
    if attribute_id.nil?   
      return attribute_model.first.id if attribute_model.first    # Return id of existing record
    end    
    # Create new detail record if attribute value is specified or it's nil and there are no existing records
    f = Factory(attribute, :id => attribute_id || UNSPECIFIED)
    if attribute_id == UNSPECIFIED
      f.update_attribute(:description, 'Unspecified') if f.respond_to? :description
      f.update_attribute(:name, 'Unspecified') if f.respond_to? :name
    end
    raise unless f.valid? 
    return f.id
  end

  # One member
  def factory_member_basic(params={})    # Not using params! Fix if needed.
    family = Factory(:family)
    head = Factory(:member, {:family=>family}.merge(params))
    family.update_attribute(:head, head)
    return head
  end    

  # A member that can be saved without saving a family
  # Note that if retrieved from the database it will no longer have a family!
  def build_member_without_family
    member = Factory.build(:member_without_family)
    member.stub(:family).and_return(Factory.stub(:family))
    return member
  end

  # Family with personnel_data, health_data, contact, field_term
  # Single by default, add :couple=>true and/or :child=>true if needed
  def factory_family_full(params={})
    head = factory_member_basic
    family = head.family
    if params[:couple]
      spouse = Factory(:member_with_details, :family=>family, :spouse=>head, :sex=>'F')
      head.spouse = spouse
    end
    add_details(head, {:personnel_data_create=>true, 
                      :health_data_create=>true,     
                      :contact_create=>true,
                      :field_term_create=>true }.merge(params))
    add_details(spouse) if head.spouse
    if params[:child]
      child = Factory(:child, :family=>family, :country=>head.country)
    end
    return family
  end

  # Same as factory_family_full but no associated records except as created automatically
  def factory_family_bare(params={})
    head = factory_member_basic
    family = head.family
    Factory(:contact, :member=>head)
    if params[:couple]
      spouse = factory_member_basic(:sex=>'F')
      head.marry spouse
      Factory(:contact, :member=>spouse)
    end
    if params[:child]
      child = Factory(:child, :family=>family, :country=>head.country)
      child.stub(:dependent).and_return(true)
    end
    return family
  end

  def factory_member_create(params={})
    number = rand(1000000)
    params[:last_name] ||= "Johnson #{number}"
    params[:first_name] ||= 'Gerald'
    params[:name] ||= "Johnson #{number}, Gerald"
    params[:sex] ||= 'M'
    params[:status_id] = create_associated_details(:status, params[:status_id], true)
#*    params[:residence_location_id] = create_associated_details(:location, params[:residence_location_id], true)
    params[:work_location_id] = create_associated_details(:location, params[:work_location_id], true)
    params[:ministry_id] = create_associated_details(:ministry, params[:ministry_id], true)
    if params[:family] 
      member = Member.create(params)
      family.head.update_attributes(params) if family.head == member
    else
      family = Family.create(:last_name=>params[:last_name],
                        :first_name=>params[:first_name],
                        :name=>params[:name],
                        :status_id=>params[:status_id],
                        :residence_location_id=>params[:residence_location_id],
                        :sim_id => rand(100000)
                        )
      member = Factory(:member, :family=>family, :last_name=>family.last_name,
          :first_name=>family.first_name, :name=>family.name, :status=>family.status,
          )
      family.update_attribute(:head, member)
    end

    puts "Error updating family or family head" unless member.valid? && member.family.valid?
    create_spouse(member) if params[:spouse]
    return member
  end
  
  def factory_member_build(params={}, options={})
    number = rand(1000000)
#    if params[:options] 
#      make_spouse = params[:options][:spouse]
#      # any other options ... process here before they're all deleted
#      params.delete[:options]
#    end
    params[:last_name] ||= "Johnson #{number}"
    params[:first_name] ||= 'Gerald'
    params[:name] ||= "Johnson #{number}, Gerald"
    params[:sex] ||= 'M'
    params[:status] ||= Factory.build(:status, params[:status] || {})
#*    params[:residence_location_id] = create_associated_details(:location, params[:residence_location_id], true)
    params[:work_location] ||= Location.new(params[:work_location] || {})
    residence_location = params.delete(:residence_location) || Location.new(params[:residence_location] || {})
    params[:ministry] ||= Ministry.new(params[:ministry] || {})
    params[:personnel_data] ||= PersonnelData.new(params[:personnel_data] || {})
    params[:family] ||= Family.new(:last_name=>params[:last_name],
                        :first_name=>params[:first_name],
                        :name=>params[:name],
                        :status=>params[:status],
                        :residence_location=>params[:residence_location],
                        :sim_id => rand(100000)
                        )
    member = Member.new(params)
    family = params[:family]
    family.head = member
    family.residence_location = residence_location
    puts "Error updating family or family head" unless member.valid? && member.family.valid?
    build_spouse(member) if options[:spouse]
    return member
  end

  def add_details(member, params={})
    location = params[:location] || Location.first || Factory(:location)
    member.update_attributes(:middle_name => 'Midname',
            :short_name => 'Shorty',
            :sex => params[:sex] || 'M',
            :birth_date => params[:birth_date] || '1980-01-01',
            :country => params[:country] || Country.first || Factory(:country),
            :status => params[:status] || Status.first || Factory(:status),
#*            :residence_location => location,
            :work_location => location,
            :ministry => Ministry.first || Factory(:ministry),
            :education => Education.first || Factory(:education),
            :ministry_comment => 'Working with orphans'
            )
    if params[:personnel_data_create]
      member.personnel_data.update_attributes(
              :date_active => params[:date_active] || '2005-01-01',
              :employment_status=> params[:employment_status] || EmploymentStatus.first || 
                  Factory(:employment_status),
              :education => params[:education] || Education.first || Factory(:education),
              :qualifications => 'TESOL, qualified midwife')
    end
    if params[:field_term_create]
      Factory(:field_term, :member=>member)  
    end
    if params[:contact_create]
      Factory(:contact, :member=>member, 
              :contact_type=>params[:contact_type] || (ContactType.first || Factory(:contact_type)))
    end
    if params[:health_data_create]
      member.health_data.update_attribute(
              :bloodtype, params[:bloodtype] || (Bloodtype.first || Factory(:bloodtype)) )
    end
  end

  def finds_recent(model)
    model_sym = model.to_s.downcase.to_sym
    describe 'finds recent' do
      before(:each) do
        member = Factory(:member_without_family)
        @old = Factory(model_sym, :member=>member, :updated_at=>Date.today-100.days)
        @new = Factory(model_sym, :member=>member, :updated_at=>Date.today)
        model.count.should == 2
      end
      
      it 'with specified duration' do
        model.recently_updated(10).all.should == [@new]
        model.recently_updated(120).all.should =~ [@new, @old]
      end
      
      it 'with default duration' do
        model.recently_updated.all.should == [@new]
      end
    end # describe 'finds recent'       
  end #finds recent
    

  def test_init
    SimTestHelper::seed_tables
    @f = Factory.create(:family)
    @h = @f.head
    @contact = Factory.create(:contact, :member => @h)
    @travel = Factory.create(:travel, :member => @h)
    @field_term = Factory.create(:field_term, :member => @h)
  end
 
  def seed_tables
    @country = Country.first || Factory.create(:country) 
    @status = Factory.create(:status)
    @state = Factory.create(:state)
    @city = Factory.create(:city)
    @location = Factory.create(:location)
    @education = Factory.create(:education)
    @employment_status = Factory.create(:employment_status)
    @ministry = Factory.create(:ministry)
    @bloodtype = Factory.create(:bloodtype)
    Factory.create(:country_unspecified) unless Country.exists?(UNSPECIFIED)
    Factory.create(:status_unspecified)
    Factory.create(:state_unspecified)
    Factory.create(:city_unspecified)
    Factory.create(:location_unspecified)
    Factory.create(:education_unspecified)
    Factory.create(:employment_status_unspecified)
    Factory.create(:ministry_unspecified)
    Factory.create(:bloodtype_unspecified)
  end

# This is just a convenient way of defining a few locations to be created 
  def locations_hash
   [ 
                  {:city=>'Jos', :city_id => 2, :description=>'Evangel', :id=>1},
                  {:city=>'Jos', :city_id => 2, :description=>'JETS', :id=>3},
                  {:city=>'Jos', :city_id => 2, :description=>'ECWA', :id=>2},
                  {:city=>'Miango', :city_id => 4, :description=>'MRH', :id=>4},
                  {:city=>'Miango', :city_id => 2, :description=>'KA', :id=>5},
                  {:city=>'Miango', :city_id => 2, :description=>'Miango Dental Clinic', :id=>6},
                  {:city=>'Kano', :city_id => 3, :description=>'Tofa Bible School', :id=>7},
                  {:city=>'Kano', :city_id => 3, :description=>'Kano Eye Hospital', :id=>8},
                  {:city=>'Abuja', :city_id => 5, :description=>'Abuja Guest House', :id=>9}
    ]
  end
  
  def setup_cities
    Factory.create(:city, :name => 'Jos', :id=>2)
    Factory.create(:city, :name => 'Kano', :id=>3)
    Factory.create(:city, :name => 'Miango', :id=>4)
    Factory.create(:city, :name => 'Abuja', :id=>5)
    Factory.create(:city_unspecified)
  end

  def setup_locations
    if City.find_by_name('Miango').nil?
      City.delete_all
      setup_cities
    end  
    locations_hash.each do |location| 
      Factory.create(:location, :id=>location[:id], :city_id=>location[:city_id],
              :description=>location[:description])
    end
    Factory.create(:location_unspecified, :city_id => 999999)
    @locations = Location.all
  end

  # Given parent (like :status) and child (like :member), check that the parent record
  # cannot be deleted if there are still children linked to it. For example, we should
  # not be able to delete a status record if there are still members who have that status.
  # Example: test_check_before_destroy(:status, :member)
  def test_check_before_destroy(parent, child)
    # Ensure that can destroy parent without child
    @parent = Factory(parent)
    lambda do
      @parent.destroy
    end.should change(parent.to_s.camelcase.constantize, :count).by(-1)
  
    @parent = Factory(parent)
    # Stub so that it appears @parent does have child records.
    @parent.stub(child.to_s.pluralize).and_return([1])
    @parent.stub(child).and_return([1])
    lambda do
      @parent.destroy
    end.should_not change(parent.to_s.camelcase.constantize, :count)
  end    
  
# see https://github.com/shyouhei/ruby/blob/trunk/ext/syck/lib/syck.rb#L436
    def y( object, *objects )
        objects.unshift object
        puts( if objects.length == 1
                  YAML.dump( *objects )
              else
                  YAML.dump_stream( *objects )
              end )
    end

  
end #Module
