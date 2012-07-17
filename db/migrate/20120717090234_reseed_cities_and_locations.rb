class ReseedCitiesAndLocations < ActiveRecord::Migration
  def up
#puts "**** Seeding cities table"
    City.delete_all
    x = City.new(:name => 'Jos',  :latitude => 9.917, :longitude => 8.9)
    x.id = 1
    x.save
    x = City.new(:name => 'Enugu',  :latitude => 6.43333, :longitude => 7.48333)
    x.id = 2
    x.save
    x = City.new(:name => 'Aba',  :latitude => 5.11667, :longitude => 7.36667)
    x.id = 9
    x.save
    x = City.new(:name => 'Egbe',  :latitude => 8.21667, :longitude => 5.51667)
    x.id = 10
    x.save
    x = City.new(:name => 'Igbaja',  :latitude => 8.38333, :longitude => 4.88333)
    x.id = 11
    x.save
    x = City.new(:name => 'Ilorin',  :latitude => 8.48, :longitude => 4.55)
    x.id = 12
    x.save
    x = City.new(:name => 'Kaiama',  :latitude => 9.6225, :longitude => 6.3)
    x.id = 13
    x.save
    x = City.new(:name => 'Abuja',  :latitude => 9.25, :longitude => 7)
    x.id = 14
    x.save
    x = City.new(:name => 'Gure',  :latitude => 10.2369, :longitude => 8.4)
    x.id = 16
    x.save
    x = City.new(:name => 'Kagoro',  :latitude => 9.6, :longitude => 8.3833)
    x.id = 18
    x.save
    x = City.new(:name => 'Adunu',  :latitude => 9.58333, :longitude => 7.15)
    x.id = 19
    x.save
    x = City.new(:name => 'Samaru',  :latitude => 9.72, :longitude => 8.4)
    x.id = 20
    x.save
    x = City.new(:name => 'Minna',  :latitude => 9.6139, :longitude => 6.5569)
    x.id = 21
    x.save
    x = City.new(:name => 'Ningi',  :latitude => 9.56968, :longitude => 11.077)
    x.id = 22
    x.save
    x = City.new(:name => 'Billiri',  :latitude => 9.86472, :longitude => 11.2253)
    x.id = 23
    x.save
    x = City.new(:name => 'Kano',  :latitude => 11.9964, :longitude => 8.51667)
    x.id = 24
    x.save
    x = City.new(:name => 'Tofa',  :latitude => 12.0133, :longitude => 8.75)
    x.id = 25
    x.save
    x = City.new(:name => 'Karu',  )
    x.id = 26
    x.save
    x = City.new(:name => 'Miango',  :latitude => 9.853, :longitude => 8.696)
    x.id = 45
    x.save
    x = City.new(:name => 'Gyero',  :latitude => 9.8162, :longitude => 8.8184)
    x.id = 46
    x.save
#puts "**** Seeding locations table"
    create_table "locations", :force => true do |t|
      t.string   "description"
      t.integer  "city_id",     :default => 999999
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "code"
    end

    add_index "locations", ["code"], :name => "index_locations_on_code", :unique => true
    add_index "locations", ["description"], :name => "index_locations_on_description", :unique => true
    x = Location.new(:description => 'Enugu', :city_id => 2, :code => 10101)
    x.id = 1
    x.save
    x = Location.new(:description => 'Aba Bible College, Abia State', :city_id => 9, :code => 10201)
    x.id = 5
    x.save
    x = Location.new(:description => 'Egbe Hospital', :city_id => 10, :code => 20101)
    x.id = 6
    x.save
    x = Location.new(:description => 'Igbaja Seminary', :city_id => 11, :code => 20201)
    x.id = 7
    x.save
    x = Location.new(:description => 'Ilorin', :city_id => 12, :code => 20300)
    x.id = 8
    x.save
    x = Location.new(:description => 'Kaiama', :city_id => 13, :code => 20400)
    x.id = 9
    x.save
    x = Location.new(:description => 'Abuja', :city_id => 14, :code => 30000)
    x.id = 10
    x.save
    x = Location.new(:description => 'Baptist Guest House Abuja', :city_id => 14, :code => 30001)
    x.id = 11
    x.save
    x = Location.new(:description => 'Gure', :city_id => 16, :code => 30201)
    x.id = 12
    x.save
    x = Location.new(:description => 'Kagoro', :city_id => 18, :code => 30300)
    x.id = 13
    x.save
    x = Location.new(:description => 'Kagoro -- Seminary', :city_id => 18, :code => 30301)
    x.id = 14
    x.save
    x = Location.new(:description => 'Adunu/ECWA/EMS', :city_id => 19, :code => 30400)
    x.id = 15
    x.save
    x = Location.new(:description => 'Samaru/ECWA Widows Sch', :city_id => 20, :code => 30401)
    x.id = 16
    x.save
    x = Location.new(:description => 'Minna', :city_id => 21, :code => 30500)
    x.id = 17
    x.save
    x = Location.new(:description => 'Ningi', :city_id => 22, :code => 40201)
    x.id = 18
    x.save
    x = Location.new(:description => 'Billiri -- ECWA Theol College', :city_id => 23, :code => 40500)
    x.id = 19
    x.save
    x = Location.new(:description => 'Kano', :city_id => 24, :code => 50101)
    x.id = 20
    x.save
    x = Location.new(:description => 'Tofa/ECWA Bible Train. Sch.', :city_id => 25, :code => 50201)
    x.id = 21
    x.save
    x = Location.new(:description => 'Jos', :city_id => 1, :code => 60100)
    x.id = 22
    x.save
    x = Location.new(:description => 'BUTH (Evangel) Hospital', :city_id => 1, :code => 60101)
    x.id = 23
    x.save
    x = Location.new(:description => 'Spring of Life', :city_id => 1, :code => 60102)
    x.id = 24
    x.save
    x = Location.new(:description => 'Gidan Bege', :city_id => 1, :code => 60105)
    x.id = 25
    x.save
    x = Location.new(:description => 'Challenge Compound', :city_id => 1, :code => 60110)
    x.id = 26
    x.save
    x = Location.new(:description => 'Jos Pharmacy Compound', :city_id => 1, :code => 60111)
    x.id = 27
    x.save
    x = Location.new(:description => 'Jos ECWA/SIM Headquarters', :city_id => 1, :code => 60112)
    x.id = 28
    x.save
    x = Location.new(:description => 'Jos Oasis Campound', :city_id => 1, :code => 60120)
    x.id = 29
    x.save
    x = Location.new(:description => 'Niger Creek Compound', :city_id => 1, :code => 60121)
    x.id = 30
    x.save
    x = Location.new(:description => 'Apollo Crescent', :city_id => 1, :code => 60122)
    x.id = 31
    x.save
    x = Location.new(:description => 'Woyke House', :city_id => 1, :code => 60123)
    x.id = 32
    x.save
    x = Location.new(:description => 'Danish Lutheran Compound', :city_id => 1, :code => 60125)
    x.id = 33
    x.save
    x = Location.new(:description => 'Hillcrest School', :city_id => 1, :code => 60126)
    x.id = 34
    x.save
    x = Location.new(:description => 'Jos CRC Mountain View', :city_id => 1, :code => 60127)
    x.id = 35
    x.save
    x = Location.new(:description => 'Jos ELM House', :city_id => 1, :code => 60128)
    x.id = 36
    x.save
    x = Location.new(:description => 'JETS', :city_id => 1, :code => 60180)
    x.id = 37
    x.save
    x = Location.new(:description => 'Word of  Life', :city_id => 1, :code => 60190)
    x.id = 38
    x.save
    x = Location.new(:description => 'Jos City Ministries', :city_id => 1, :code => 60192)
    x.id = 39
    x.save
    x = Location.new(:description => 'Miango', :city_id => 45, :code => 60200)
    x.id = 40
    x.save
    x = Location.new(:description => 'Miango MRH', :city_id => 45, :code => 60201)
    x.id = 41
    x.save
    x = Location.new(:description => 'Miango Kent Academy', :city_id => 45, :code => 60202)
    x.id = 42
    x.save
    x = Location.new(:description => 'Miango Dental Clinic', :city_id => 45, :code => 60203)
    x.id = 43
    x.save
    x = Location.new(:description => 'Karu--Seminary', :city_id => 26, :code => 30101)
    x.id = 44
    x.save
  end

  def down
  end
end
