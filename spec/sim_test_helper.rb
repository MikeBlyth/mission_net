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
