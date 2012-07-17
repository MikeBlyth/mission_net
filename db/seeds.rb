# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#
# We use id = 999999 for all "unspecified" values. For example, unknown or unspecified blood_type is represented by
# the blood_type record with id = 999999.
#
# coding: utf-8

#puts "**** Seeding tables ****"
Bloodtype.delete_all
x = Bloodtype.new(:abo => 'A', :rh => 'neg', :comment => '', :full => 'A neg')
x.id = 1
x.save
x = Bloodtype.new(:abo => 'A', :rh => '+', :comment => '', :full => 'A+')
x.id = 2
x.save
x = Bloodtype.new(:abo => 'A', :rh => ' Rh?', :comment => 'type A, unknown Rh', :full => 'A')
x.id = 3
x.save
x = Bloodtype.new(:abo => 'B', :rh => 'neg', :comment => '', :full => 'B neg')
x.id = 4
x.save
x = Bloodtype.new(:abo => 'B', :rh => '+', :comment => '', :full => 'B+')
x.id = 5
x.save
x = Bloodtype.new(:abo => 'B', :rh => ' Rh?', :comment => 'type B, unknown Rh', :full => 'B')
x.id = 6
x.save
x = Bloodtype.new(:abo => 'O', :rh => 'neg', :comment => '', :full => 'O neg')
x.id = 7
x.save
x = Bloodtype.new(:abo => 'O', :rh => '+', :comment => '', :full => 'O+')
x.id = 8
x.save
x = Bloodtype.new(:abo => 'O', :rh => ' Rh?', :comment => 'type O, unknown Rh', :full => 'O')
x.id = 9
x.save
x = Bloodtype.new(:abo => '?ABO', :rh => '+', :comment => 'unknown ABO; Rh+', :full => 'something +')
x.id = 10
x.save
x = Bloodtype.new(:abo => '?ABO', :rh => 'neg', :comment => 'unknown ABO; Rh neg', :full => 'something neg')
x.id = 11
x.save
x = Bloodtype.new(:abo => 'AB', :rh => ' Rh?', :comment => 'type AB, unknown Rh', :full => 'AB')
x.id = 12
x.save
x = Bloodtype.new(:abo => 'AB', :rh => '+', :comment => '', :full => 'AB+')
x.id = 13
x.save
x = Bloodtype.new(:abo => 'AB', :rh => 'neg', :comment => '', :full => 'AB neg')
x.id = 14
x.save
x = Bloodtype.new(:abo => '', :rh => '', :comment => 'unknown', :full => 'unknown')
#puts "**** Seeding cities table"
City.delete_all
x = City.new(:name => 'Jos', :state => 'Plateau', :country => 'NG', :latitude => 9.917, :longitude => 8.9)
x.id = 1
x.save
x = City.new(:name => 'Enugu', :state => 'Abia', :country => 'NG', :latitude => 6.43333, :longitude => 7.48333)
x.id = 2
x.save
x = City.new(:name => 'Aba', :state => 'Abia', :country => 'NG', :latitude => 5.11667, :longitude => 7.36667)
x.id = 9
x.save
x = City.new(:name => 'Egbe', :state => 'Kogi', :country => 'NG', :latitude => 8.21667, :longitude => 5.51667)
x.id = 10
x.save
x = City.new(:name => 'Igbaja', :state => 'Kwara', :country => 'NG', :latitude => 8.38333, :longitude => 4.88333)
x.id = 11
x.save
x = City.new(:name => 'Ilorin', :state => 'Kwara', :country => 'NG', :latitude => 8.48, :longitude => 4.55)
x.id = 12
x.save
x = City.new(:name => 'Kaiama', :state => 'Kwara', :country => 'NG', :latitude => 9.6225, :longitude => 6.3)
x.id = 13
x.save
x = City.new(:name => 'Abuja', :state => 'Federal Capital Territory', :country => 'NG', :latitude => 9.25, :longitude => 7)
x.id = 14
x.save
x = City.new(:name => 'Gure', :state => 'Kaduna', :country => 'NG', :latitude => 10.2369, :longitude => 8.4)
x.id = 16
x.save
x = City.new(:name => 'Kagoro', :state => 'Kaduna', :country => 'NG', :latitude => 9.6, :longitude => 8.3833)
x.id = 18
x.save
x = City.new(:name => 'Adunu', :state => 'Kaduna', :country => 'NG', :latitude => 9.58333, :longitude => 7.15)
x.id = 19
x.save
x = City.new(:name => 'Samaru', :state => 'Kaduna', :country => 'NG', :latitude => 9.72, :longitude => 8.4)
x.id = 20
x.save
x = City.new(:name => 'Minna', :state => 'Niger', :country => 'NG', :latitude => 9.6139, :longitude => 6.5569)
x.id = 21
x.save
x = City.new(:name => 'Ningi', :state => 'Bauchi', :country => 'NG', :latitude => 9.56968, :longitude => 11.077)
x.id = 22
x.save
x = City.new(:name => 'Billiri', :state => 'Gombe', :country => 'NG', :latitude => 9.86472, :longitude => 11.2253)
x.id = 23
x.save
x = City.new(:name => 'Kano', :state => 'Kano', :country => 'NG', :latitude => 11.9964, :longitude => 8.51667)
x.id = 24
x.save
x = City.new(:name => 'Tofa', :state => 'Kano', :country => 'NG', :latitude => 12.0133, :longitude => 8.75)
x.id = 25
x.save
x = City.new(:name => 'Karu', :state => 'Federal Capital Territory', :country => 'NG')
x.id = 26
x.save
x = City.new(:name => 'Miango', :state => 'Plateau', :country => 'NG', :latitude => 9.853, :longitude => 8.696)
x.id = 45
x.save
x = City.new(:name => 'Gyero', :state => 'Plateau', :country => 'NG', :latitude => 9.8162, :longitude => 8.8184)
x.id = 46
x.save
x = City.new(:name => 'unspecified', :state => '', :country => '??')
x.id = 999999
x.save
unspecified_city_id = x.id   # We save this to use in the unspecified location record (see below)
x.id = 999999
x.save

#puts "**** Seeding countries table"
Country.delete_all
x = Country.new(:code => 'AD', :name => 'Andorra', :nationality => 'Andorran', :include_in_selection => 0)
x.id = 1
x.save
x = Country.new(:code => 'AE', :name => 'United Arab Emirates', :nationality => '', :include_in_selection => 0)
x.id = 2
x.save
x = Country.new(:code => 'AF', :name => 'Afghanistan', :nationality => 'Afghan', :include_in_selection => 0)
x.id = 3
x.save
x = Country.new(:code => 'AG', :name => 'Antigua and Barbuda', :nationality => 'Antiguan', :include_in_selection => 0)
x.id = 4
x.save
x = Country.new(:code => 'AI', :name => 'Anguilla', :nationality => 'Anguillan', :include_in_selection => 0)
x.id = 5
x.save
x = Country.new(:code => 'AL', :name => 'Albania', :nationality => 'Albanian', :include_in_selection => 0)
x.id = 6
x.save
x = Country.new(:code => 'AM', :name => 'Armenia', :nationality => 'Armenian', :include_in_selection => 0)
x.id = 7
x.save
x = Country.new(:code => 'AN', :name => 'Netherlands Antilles', :nationality => 'Dutch Antillesian', :include_in_selection => 0)
x.id = 8
x.save
x = Country.new(:code => 'AO', :name => 'Angola', :nationality => 'Angolan', :include_in_selection => 0)
x.id = 9
x.save
x = Country.new(:code => 'AQ', :name => 'Antarctica', :nationality => 'Antarctica', :include_in_selection => 0)
x.id = 10
x.save
x = Country.new(:code => 'AR', :name => 'Argentina', :nationality => 'Argentine', :include_in_selection => 1)
x.id = 11
x.save
x = Country.new(:code => 'AS', :name => 'American Samoa', :nationality => 'American Samoan', :include_in_selection => 0)
x.id = 12
x.save
x = Country.new(:code => 'AT', :name => 'Austria', :nationality => 'Austrian', :include_in_selection => 1)
x.id = 13
x.save
x = Country.new(:code => 'AU', :name => 'Australia', :nationality => 'Australian', :include_in_selection => 1)
x.id = 14
x.save
x = Country.new(:code => 'AW', :name => 'Aruba', :nationality => 'Aruban', :include_in_selection => 0)
x.id = 15
x.save
x = Country.new(:code => 'AX', :name => 'Åland Islands ', :nationality => 'Åland Islands', :include_in_selection => 0)
x.id = 16
x.save
x = Country.new(:code => 'AZ', :name => 'Azerbaijan', :nationality => 'Azerbaijanian', :include_in_selection => 0)
x.id = 17
x.save
x = Country.new(:code => 'BA', :name => 'Bosnia and Herzegovina', :nationality => 'Bosnian/Herzegovinan', :include_in_selection => 0)
x.id = 18
x.save
x = Country.new(:code => 'BB', :name => 'Barbados', :nationality => 'Barbadian', :include_in_selection => 0)
x.id = 19
x.save
x = Country.new(:code => 'BD', :name => 'Bangladesh', :nationality => 'Bangladeshi', :include_in_selection => 0)
x.id = 20
x.save
x = Country.new(:code => 'BE', :name => 'Belgium', :nationality => 'Belgian', :include_in_selection => 1)
x.id = 21
x.save
x = Country.new(:code => 'BF', :name => 'Burkina Faso', :nationality => 'Burkinabe', :include_in_selection => 0)
x.id = 22
x.save
x = Country.new(:code => 'BG', :name => 'Bulgaria', :nationality => 'Bulgarian', :include_in_selection => 0)
x.id = 23
x.save
x = Country.new(:code => 'BH', :name => 'Bahrain', :nationality => 'Bahraini', :include_in_selection => 0)
x.id = 24
x.save
x = Country.new(:code => 'BI', :name => 'Burundi', :nationality => 'Burundian', :include_in_selection => 0)
x.id = 25
x.save
x = Country.new(:code => 'BJ', :name => 'Benin', :nationality => 'Beninois', :include_in_selection => 0)
x.id = 26
x.save
x = Country.new(:code => 'BM', :name => 'Bermuda', :nationality => 'Bermudian', :include_in_selection => 0)
x.id = 27
x.save
x = Country.new(:code => 'BN', :name => 'Brunei Darussalam', :nationality => 'Bruneian', :include_in_selection => 0)
x.id = 28
x.save
x = Country.new(:code => 'BO', :name => 'Bolivia', :nationality => 'Bolivian', :include_in_selection => 1)
x.id = 29
x.save
x = Country.new(:code => 'BR', :name => 'Brazil', :nationality => 'Brazilian', :include_in_selection => 1)
x.id = 30
x.save
x = Country.new(:code => 'BS', :name => 'Bahamas', :nationality => 'Bahamian', :include_in_selection => 0)
x.id = 31
x.save
x = Country.new(:code => 'BT', :name => 'Bhutan', :nationality => 'Bhutanese', :include_in_selection => 0)
x.id = 32
x.save
x = Country.new(:code => 'BV', :name => 'Bouvet Island', :nationality => 'Bouvet Islander', :include_in_selection => 0)
x.id = 33
x.save
x = Country.new(:code => 'BW', :name => 'Botswana', :nationality => 'Botswanan', :include_in_selection => 0)
x.id = 34
x.save
x = Country.new(:code => 'BY', :name => 'Belarus', :nationality => 'Belarusian', :include_in_selection => 0)
x.id = 35
x.save
x = Country.new(:code => 'BZ', :name => 'Belize', :nationality => 'Belizean', :include_in_selection => 0)
x.id = 36
x.save
x = Country.new(:code => 'CA', :name => 'Canada', :nationality => 'Canadian', :include_in_selection => 1)
x.id = 37
x.save
x = Country.new(:code => 'CC', :name => 'Cocos (Keeling) Islands', :nationality => 'Cocos Island', :include_in_selection => 0)
x.id = 38
x.save
x = Country.new(:code => 'CD', :name => 'Congo, Democratic Republic', :nationality => 'Congolese', :include_in_selection => 0)
x.id = 39
x.save
x = Country.new(:code => 'CF', :name => 'Central African Republic', :nationality => 'Central African', :include_in_selection => 0)
x.id = 40
x.save
x = Country.new(:code => 'CG', :name => 'Congo', :nationality => 'Congolese', :include_in_selection => 0)
x.id = 41
x.save
x = Country.new(:code => 'CH', :name => 'Switzerland', :nationality => 'Swiss', :include_in_selection => 1)
x.id = 42
x.save
x = Country.new(:code => 'CK', :name => 'Cook Islands', :nationality => 'Cook Island', :include_in_selection => 0)
x.id = 43
x.save
x = Country.new(:code => 'CL', :name => 'Chile', :nationality => 'Chilean', :include_in_selection => 1)
x.id = 44
x.save
x = Country.new(:code => 'CM', :name => 'Cameroon', :nationality => 'Cameroonian', :include_in_selection => 1)
x.id = 45
x.save
x = Country.new(:code => 'CN', :name => 'China', :nationality => 'Chinese', :include_in_selection => 1)
x.id = 46
x.save
x = Country.new(:code => 'CO', :name => 'Colombia', :nationality => 'Colombian', :include_in_selection => 1)
x.id = 47
x.save
x = Country.new(:code => 'CR', :name => 'Costa Rica', :nationality => 'Costa Rican', :include_in_selection => 0)
x.id = 48
x.save
x = Country.new(:code => 'CU', :name => 'Cuba', :nationality => 'Cuban', :include_in_selection => 0)
x.id = 49
x.save
x = Country.new(:code => 'CV', :name => 'Cape Verde', :nationality => 'Cape Verdean', :include_in_selection => 0)
x.id = 50
x.save
x = Country.new(:code => 'CX', :name => 'Christmas Island', :nationality => 'Christmas Island', :include_in_selection => 0)
x.id = 51
x.save
x = Country.new(:code => 'CY', :name => 'Cyprus', :nationality => 'Cypriot', :include_in_selection => 0)
x.id = 52
x.save
x = Country.new(:code => 'CZ', :name => 'Czech Republic', :nationality => 'Czech', :include_in_selection => 1)
x.id = 53
x.save
x = Country.new(:code => 'DE', :name => 'Germany', :nationality => 'German', :include_in_selection => 1)
x.id = 54
x.save
x = Country.new(:code => 'DJ', :name => 'Djibouti', :nationality => 'Djibouti', :include_in_selection => 0)
x.id = 55
x.save
x = Country.new(:code => 'DK', :name => 'Denmark', :nationality => 'Danish', :include_in_selection => 1)
x.id = 56
x.save
x = Country.new(:code => 'DM', :name => 'Dominica', :nationality => 'Dominican', :include_in_selection => 0)
x.id = 57
x.save
x = Country.new(:code => 'DO', :name => 'Dominican Republic', :nationality => 'Dominican', :include_in_selection => 0)
x.id = 58
x.save
x = Country.new(:code => 'DZ', :name => 'Algeria', :nationality => 'Algerian', :include_in_selection => 0)
x.id = 59
x.save
x = Country.new(:code => 'EC', :name => 'Ecuador', :nationality => 'Ecuadorian', :include_in_selection => 1)
x.id = 60
x.save
x = Country.new(:code => 'EE', :name => 'Estonia', :nationality => 'Estonian', :include_in_selection => 1)
x.id = 61
x.save
x = Country.new(:code => 'EG', :name => 'Egypt', :nationality => 'Egyptian', :include_in_selection => 1)
x.id = 62
x.save
x = Country.new(:code => 'EH', :name => 'Western Sahara', :nationality => 'Sahrawi', :include_in_selection => 0)
x.id = 63
x.save
x = Country.new(:code => 'ER', :name => 'Eritrea', :nationality => 'Eritrean', :include_in_selection => 0)
x.id = 64
x.save
x = Country.new(:code => 'ES', :name => 'Spain', :nationality => 'Spanish', :include_in_selection => 1)
x.id = 65
x.save
x = Country.new(:code => 'ET', :name => 'Ethiopia', :nationality => 'Ethiopian', :include_in_selection => 0)
x.id = 66
x.save
x = Country.new(:code => 'FI', :name => 'Finland', :nationality => 'Finnish', :include_in_selection => 1)
x.id = 67
x.save
x = Country.new(:code => 'FJ', :name => 'Fiji', :nationality => 'Fijian', :include_in_selection => 0)
x.id = 68
x.save
x = Country.new(:code => 'FK', :name => 'Falkland Islands (Malvinas)', :nationality => 'Falkland Island', :include_in_selection => 0)
x.id = 69
x.save
x = Country.new(:code => 'FM', :name => 'Micronesia', :nationality => 'Micronesian', :include_in_selection => 0)
x.id = 70
x.save
x = Country.new(:code => 'FO', :name => 'Faroe Islands', :nationality => 'Faroese', :include_in_selection => 0)
x.id = 71
x.save
x = Country.new(:code => 'FR', :name => 'France', :nationality => 'French', :include_in_selection => 1)
x.id = 72
x.save
x = Country.new(:code => 'GA', :name => 'Gabon', :nationality => 'Gabonese', :include_in_selection => 0)
x.id = 73
x.save
x = Country.new(:code => 'UK', :name => 'United Kingdom', :nationality => 'British', :include_in_selection => 1)
x.id = 74
x.save
x = Country.new(:code => 'GD', :name => 'Grenada', :nationality => 'Grenadian', :include_in_selection => 0)
x.id = 75
x.save
x = Country.new(:code => 'GE', :name => 'Georgia', :nationality => 'Georgian', :include_in_selection => 0)
x.id = 76
x.save
x = Country.new(:code => 'GF', :name => 'French Guiana', :nationality => 'French Guianese', :include_in_selection => 0)
x.id = 77
x.save
x = Country.new(:code => 'GG', :name => 'Guernsey', :nationality => '', :include_in_selection => 0)
x.id = 78
x.save
x = Country.new(:code => 'GH', :name => 'Ghana', :nationality => 'Ghanaian', :include_in_selection => 1)
x.id = 79
x.save
x = Country.new(:code => 'GI', :name => 'Gibraltar', :nationality => 'Gibraltar', :include_in_selection => 0)
x.id = 80
x.save
x = Country.new(:code => 'GL', :name => 'Greenland', :nationality => 'Greenlandic', :include_in_selection => 0)
x.id = 81
x.save
x = Country.new(:code => 'GM', :name => 'Gambia', :nationality => 'Gambian', :include_in_selection => 0)
x.id = 82
x.save
x = Country.new(:code => 'GN', :name => 'Guinea', :nationality => 'Guinean', :include_in_selection => 0)
x.id = 83
x.save
x = Country.new(:code => 'GP', :name => 'Guadeloupe', :nationality => 'Guadeloupe', :include_in_selection => 0)
x.id = 84
x.save
x = Country.new(:code => 'GQ', :name => 'Equatorial Guinea', :nationality => 'Equatorial Guinean', :include_in_selection => 0)
x.id = 85
x.save
x = Country.new(:code => 'GR', :name => 'Greece', :nationality => 'Greek', :include_in_selection => 1)
x.id = 86
x.save
x = Country.new(:code => 'GS', :name => 'South Georgia and South Sandwich Islands', :nationality => 'South Georgia Island', :include_in_selection => 0)
x.id = 87
x.save
x = Country.new(:code => 'GT', :name => 'Guatemala', :nationality => 'Guatemalan', :include_in_selection => 1)
x.id = 88
x.save
x = Country.new(:code => 'GU', :name => 'Guam', :nationality => 'Guamanian', :include_in_selection => 0)
x.id = 89
x.save
x = Country.new(:code => 'GW', :name => 'Guinea-Bissau', :nationality => 'Guinean', :include_in_selection => 0)
x.id = 90
x.save
x = Country.new(:code => 'GY', :name => 'Guyana', :nationality => 'Guyanese', :include_in_selection => 0)
x.id = 91
x.save
x = Country.new(:code => 'HK', :name => 'Hong Kong', :nationality => 'Hong Kong', :include_in_selection => 1)
x.id = 92
x.save
x = Country.new(:code => 'HM', :name => 'Heard Island and McDonald Islands', :nationality => '', :include_in_selection => 0)
x.id = 93
x.save
x = Country.new(:code => 'HN', :name => 'Honduras', :nationality => 'Honduran', :include_in_selection => 1)
x.id = 94
x.save
x = Country.new(:code => 'HR', :name => 'Croatia', :nationality => 'Croatian', :include_in_selection => 0)
x.id = 95
x.save
x = Country.new(:code => 'HT', :name => 'Haiti', :nationality => 'Hatian', :include_in_selection => 0)
x.id = 96
x.save
x = Country.new(:code => 'HU', :name => 'Hungary', :nationality => 'Hungarian', :include_in_selection => 0)
x.id = 97
x.save
x = Country.new(:code => 'ID', :name => 'Indonesia', :nationality => 'Indonesian', :include_in_selection => 0)
x.id = 98
x.save
x = Country.new(:code => 'IE', :name => 'Ireland (Republic)', :nationality => 'Irish', :include_in_selection => 1)
x.id = 99
x.save
x = Country.new(:code => 'IL', :name => 'Israel', :nationality => 'Israeli', :include_in_selection => 0)
x.id = 100
x.save
x = Country.new(:code => 'IM', :name => 'Isle of Man', :nationality => 'Manx', :include_in_selection => 0)
x.id = 101
x.save
x = Country.new(:code => 'IN', :name => 'India', :nationality => 'Indian', :include_in_selection => 1)
x.id = 102
x.save
x = Country.new(:code => 'IO', :name => 'British Indian Ocean Territory', :nationality => 'British', :include_in_selection => 0)
x.id = 103
x.save
x = Country.new(:code => 'IQ', :name => 'Iraq', :nationality => 'Iraqi', :include_in_selection => 0)
x.id = 104
x.save
x = Country.new(:code => 'IR', :name => 'Iran', :nationality => 'Iranian', :include_in_selection => 0)
x.id = 105
x.save
x = Country.new(:code => 'IS', :name => 'Iceland', :nationality => 'Icelandic', :include_in_selection => 0)
x.id = 106
x.save
x = Country.new(:code => 'IT', :name => 'Italy', :nationality => 'Italian', :include_in_selection => 1)
x.id = 107
x.save
x = Country.new(:code => 'JE', :name => 'Jersey', :nationality => '', :include_in_selection => 0)
x.id = 108
x.save
x = Country.new(:code => 'JM', :name => 'Jamaica', :nationality => 'Jamaican', :include_in_selection => 0)
x.id = 109
x.save
x = Country.new(:code => 'JO', :name => 'Jordan', :nationality => 'Jordanian', :include_in_selection => 0)
x.id = 110
x.save
x = Country.new(:code => 'JP', :name => 'Japan', :nationality => 'Japanese', :include_in_selection => 0)
x.id = 111
x.save
x = Country.new(:code => 'KE', :name => 'Kenya', :nationality => 'Kenyan', :include_in_selection => 1)
x.id = 112
x.save
x = Country.new(:code => 'KG', :name => 'Kyrgyzstan', :nationality => 'Kyrgyz', :include_in_selection => 0)
x.id = 113
x.save
x = Country.new(:code => 'KH', :name => 'Cambodia', :nationality => 'Cambodian', :include_in_selection => 0)
x.id = 114
x.save
x = Country.new(:code => 'KI', :name => 'Kiribati', :nationality => 'Kiribati', :include_in_selection => 0)
x.id = 115
x.save
x = Country.new(:code => 'KM', :name => 'Comoros', :nationality => 'Comorian', :include_in_selection => 0)
x.id = 116
x.save
x = Country.new(:code => 'KN', :name => 'Saint Kitts and Nevis', :nationality => 'Kittinian/Nevisian', :include_in_selection => 0)
x.id = 117
x.save
x = Country.new(:code => 'KO', :name => 'South Korea', :nationality => 'Korean', :include_in_selection => 1)
x.id = 118
x.save
x = Country.new(:code => 'KW', :name => 'Kuwait', :nationality => 'Kuwaiti', :include_in_selection => 0)
x.id = 119
x.save
x = Country.new(:code => 'KY', :name => 'Cayman Islands', :nationality => 'Cayman Island', :include_in_selection => 0)
x.id = 120
x.save
x = Country.new(:code => 'KZ', :name => 'Kazakhstan', :nationality => 'Kazakh', :include_in_selection => 0)
x.id = 121
x.save
x = Country.new(:code => 'LA', :name => 'Laos', :nationality => 'Laotian', :include_in_selection => 0)
x.id = 122
x.save
x = Country.new(:code => 'LB', :name => 'Lebanon', :nationality => 'Lebanese', :include_in_selection => 1)
x.id = 123
x.save
x = Country.new(:code => 'LC', :name => 'Saint Lucia', :nationality => 'Saint Lucian', :include_in_selection => 0)
x.id = 124
x.save
x = Country.new(:code => 'LI', :name => 'Liechtenstein', :nationality => 'Liechtenstein', :include_in_selection => 0)
x.id = 125
x.save
x = Country.new(:code => 'LK', :name => 'Sri Lanka', :nationality => 'Sri Lankan', :include_in_selection => 1)
x.id = 126
x.save
x = Country.new(:code => 'LR', :name => 'Liberia', :nationality => 'Liberian', :include_in_selection => 1)
x.id = 127
x.save
x = Country.new(:code => 'LS', :name => 'Lesotho', :nationality => 'Basotho (Lesostho)', :include_in_selection => 0)
x.id = 128
x.save
x = Country.new(:code => 'LT', :name => 'Lithuania', :nationality => 'Lithuanian', :include_in_selection => 1)
x.id = 129
x.save
x = Country.new(:code => 'LU', :name => 'Luxembourg', :nationality => 'Luxembourg', :include_in_selection => 1)
x.id = 130
x.save
x = Country.new(:code => 'LV', :name => 'Latvia', :nationality => 'Latvian', :include_in_selection => 1)
x.id = 131
x.save
x = Country.new(:code => 'LY', :name => 'Libya', :nationality => 'Libyan', :include_in_selection => 0)
x.id = 132
x.save
x = Country.new(:code => 'MA', :name => 'Morocco', :nationality => 'Moroccan', :include_in_selection => 0)
x.id = 133
x.save
x = Country.new(:code => 'MC', :name => 'Monaco', :nationality => 'Monacan', :include_in_selection => 0)
x.id = 134
x.save
x = Country.new(:code => 'MD', :name => 'Moldova', :nationality => 'Moldovan', :include_in_selection => 0)
x.id = 135
x.save
x = Country.new(:code => 'ME', :name => 'Montenegro', :nationality => 'Montenegrin', :include_in_selection => 0)
x.id = 136
x.save
x = Country.new(:code => 'MF', :name => 'Saint Martin', :nationality => '', :include_in_selection => 0)
x.id = 137
x.save
x = Country.new(:code => 'MG', :name => 'Madagascar', :nationality => 'Malagasy', :include_in_selection => 0)
x.id = 138
x.save
x = Country.new(:code => 'MH', :name => 'Marshall Islands', :nationality => 'Marshall Island', :include_in_selection => 0)
x.id = 139
x.save
x = Country.new(:code => 'MK', :name => 'Macedonia', :nationality => 'Macedonian', :include_in_selection => 0)
x.id = 140
x.save
x = Country.new(:code => 'ML', :name => 'Mali', :nationality => 'Malian', :include_in_selection => 0)
x.id = 141
x.save
x = Country.new(:code => 'MM', :name => 'Myanmar', :nationality => 'Burmese', :include_in_selection => 0)
x.id = 142
x.save
x = Country.new(:code => 'MN', :name => 'Mongolia', :nationality => 'Mongolian', :include_in_selection => 0)
x.id = 143
x.save
x = Country.new(:code => 'MO', :name => 'Macao', :nationality => 'Chinese', :include_in_selection => 0)
x.id = 144
x.save
x = Country.new(:code => 'MP', :name => 'Northern Mariana Islands', :nationality => 'Northern Marianan', :include_in_selection => 0)
x.id = 145
x.save
x = Country.new(:code => 'MQ', :name => 'Martinique', :nationality => 'Martinican', :include_in_selection => 0)
x.id = 146
x.save
x = Country.new(:code => 'MR', :name => 'Mauritania', :nationality => 'Mauritanian', :include_in_selection => 0)
x.id = 147
x.save
x = Country.new(:code => 'MS', :name => 'Montserrat', :nationality => 'Montserratian', :include_in_selection => 0)
x.id = 148
x.save
x = Country.new(:code => 'MT', :name => 'Malta', :nationality => 'Maltese', :include_in_selection => 0)
x.id = 149
x.save
x = Country.new(:code => 'MU', :name => 'Mauritius', :nationality => 'Mauritian', :include_in_selection => 0)
x.id = 150
x.save
x = Country.new(:code => 'MV', :name => 'Maldives', :nationality => 'Maldivian', :include_in_selection => 0)
x.id = 151
x.save
x = Country.new(:code => 'MW', :name => 'Malawi', :nationality => 'Malawian', :include_in_selection => 0)
x.id = 152
x.save
x = Country.new(:code => 'MX', :name => 'Mexico', :nationality => 'Mexican', :include_in_selection => 1)
x.id = 153
x.save
x = Country.new(:code => 'MY', :name => 'Malaysia', :nationality => 'Malaysian', :include_in_selection => 1)
x.id = 154
x.save
x = Country.new(:code => 'MZ', :name => 'Mozambique', :nationality => 'Mozambican', :include_in_selection => 0)
x.id = 155
x.save
x = Country.new(:code => 'NA', :name => 'Namibia', :nationality => 'Namibian', :include_in_selection => 0)
x.id = 156
x.save
x = Country.new(:code => 'NC', :name => 'New Caledonia', :nationality => 'New Caledonian', :include_in_selection => 0)
x.id = 157
x.save
x = Country.new(:code => 'NE', :name => 'Niger', :nationality => 'Nigerien', :include_in_selection => 1)
x.id = 158
x.save
x = Country.new(:code => 'NF', :name => 'Norfolk Island', :nationality => 'Norfolk Island', :include_in_selection => 0)
x.id = 159
x.save
x = Country.new(:code => 'NG', :name => 'Nigeria', :nationality => 'Nigerian', :include_in_selection => 1)
x.id = 160
x.save
x = Country.new(:code => 'NI', :name => 'Nicaragua', :nationality => 'Nicaraguan', :include_in_selection => 0)
x.id = 161
x.save
x = Country.new(:code => 'NL', :name => 'Netherlands', :nationality => 'Dutch', :include_in_selection => 1)
x.id = 162
x.save
x = Country.new(:code => 'NO', :name => 'Norway', :nationality => 'Norwegian', :include_in_selection => 1)
x.id = 163
x.save
x = Country.new(:code => 'NP', :name => 'Nepal', :nationality => 'Nepalese', :include_in_selection => 1)
x.id = 164
x.save
x = Country.new(:code => 'NR', :name => 'Nauru', :nationality => 'Nauruan', :include_in_selection => 0)
x.id = 165
x.save
x = Country.new(:code => 'NU', :name => 'Niue', :nationality => 'Niuean', :include_in_selection => 0)
x.id = 166
x.save
x = Country.new(:code => 'NZ', :name => 'New Zealand', :nationality => 'New Zealand', :include_in_selection => 1)
x.id = 167
x.save
x = Country.new(:code => 'OM', :name => 'Oman', :nationality => 'Omani', :include_in_selection => 0)
x.id = 168
x.save
x = Country.new(:code => 'PA', :name => 'Panama', :nationality => 'Panamanian', :include_in_selection => 1)
x.id = 169
x.save
x = Country.new(:code => 'PE', :name => 'Peru', :nationality => 'Peruvian', :include_in_selection => 0)
x.id = 170
x.save
x = Country.new(:code => 'PF', :name => 'French Polynesia', :nationality => 'French Polynesian', :include_in_selection => 0)
x.id = 171
x.save
x = Country.new(:code => 'PG', :name => 'Papua New Guinea', :nationality => 'Papua New Guinean', :include_in_selection => 1)
x.id = 172
x.save
x = Country.new(:code => 'PH', :name => 'Philippines', :nationality => 'Filipino', :include_in_selection => 1)
x.id = 173
x.save
x = Country.new(:code => 'PK', :name => 'Pakistan', :nationality => 'Pakistani', :include_in_selection => 0)
x.id = 174
x.save
x = Country.new(:code => 'PL', :name => 'Poland', :nationality => 'Polish', :include_in_selection => 1)
x.id = 175
x.save
x = Country.new(:code => 'PM', :name => 'Saint Pierre and Miquelon', :nationality => 'Saint-Pierrais', :include_in_selection => 0)
x.id = 176
x.save
x = Country.new(:code => 'PN', :name => 'Pitcairn Island', :nationality => 'Pitcairn Island', :include_in_selection => 0)
x.id = 177
x.save
x = Country.new(:code => 'PR', :name => 'Puerto Rico', :nationality => 'Puerto Rican', :include_in_selection => 0)
x.id = 178
x.save
x = Country.new(:code => 'PS', :name => 'Palestine', :nationality => 'Palestinian', :include_in_selection => 0)
x.id = 179
x.save
x = Country.new(:code => 'PT', :name => 'Portugal', :nationality => 'Portuguese', :include_in_selection => 1)
x.id = 180
x.save
x = Country.new(:code => 'PW', :name => 'Palau', :nationality => 'Paluan', :include_in_selection => 0)
x.id = 181
x.save
x = Country.new(:code => 'PY', :name => 'Paraguay', :nationality => 'Paraguayan', :include_in_selection => 0)
x.id = 182
x.save
x = Country.new(:code => 'QA', :name => 'Qatar', :nationality => 'Qatari', :include_in_selection => 0)
x.id = 183
x.save
x = Country.new(:code => 'RE', :name => 'Réunion', :nationality => 'Réunionese', :include_in_selection => 0)
x.id = 184
x.save
x = Country.new(:code => 'RO', :name => 'Romania', :nationality => 'Romanian', :include_in_selection => 0)
x.id = 185
x.save
x = Country.new(:code => 'RS', :name => 'Serbia', :nationality => 'Serbian', :include_in_selection => 1)
x.id = 186
x.save
x = Country.new(:code => 'RU', :name => 'Russia', :nationality => 'Russian', :include_in_selection => 1)
x.id = 187
x.save
x = Country.new(:code => 'RW', :name => 'Rwanda', :nationality => 'Rwandan', :include_in_selection => 0)
x.id = 188
x.save
x = Country.new(:code => 'SA', :name => 'Saudi Arabia', :nationality => 'Saudi Arabian', :include_in_selection => 0)
x.id = 189
x.save
x = Country.new(:code => 'SB', :name => 'Solomon Islands', :nationality => 'Solomon Island', :include_in_selection => 0)
x.id = 190
x.save
x = Country.new(:code => 'SC', :name => 'Seychelles', :nationality => 'Seychellois', :include_in_selection => 0)
x.id = 191
x.save
x = Country.new(:code => 'SD', :name => 'Sudan', :nationality => 'Sudanese', :include_in_selection => 0)
x.id = 192
x.save
x = Country.new(:code => 'SE', :name => 'Sweden', :nationality => 'Swedish', :include_in_selection => 1)
x.id = 193
x.save
x = Country.new(:code => 'SG', :name => 'Singapore', :nationality => 'Singaporean', :include_in_selection => 1)
x.id = 194
x.save
x = Country.new(:code => 'SH', :name => 'Saint Helena, Ascension and Tristan da Cunha', :nationality => 'Saint Helenian', :include_in_selection => 0)
x.id = 195
x.save
x = Country.new(:code => 'SI', :name => 'Slovenia', :nationality => 'Slovenian', :include_in_selection => 0)
x.id = 196
x.save
x = Country.new(:code => 'SJ', :name => 'Svalbard and Jan Mayen', :nationality => '', :include_in_selection => 0)
x.id = 197
x.save
x = Country.new(:code => 'SL', :name => 'Sierra Leone', :nationality => 'Sierra Leonean', :include_in_selection => 0)
x.id = 199
x.save
x = Country.new(:code => 'SM', :name => 'San Marino', :nationality => 'Sammarinese', :include_in_selection => 0)
x.id = 200
x.save
x = Country.new(:code => 'SN', :name => 'Senegal', :nationality => 'Senegalese', :include_in_selection => 0)
x.id = 201
x.save
x = Country.new(:code => 'SO', :name => 'Somalia', :nationality => 'Somali', :include_in_selection => 0)
x.id = 202
x.save
x = Country.new(:code => 'SR', :name => 'Suriname', :nationality => 'Surinamese', :include_in_selection => 0)
x.id = 203
x.save
x = Country.new(:code => 'ST', :name => 'SÃ£o TomÃ© and PrÃ­ncipe', :nationality => 'SÃ£o TomÃ©an', :include_in_selection => 0)
x.id = 204
x.save
x = Country.new(:code => 'SV', :name => 'El Salvador', :nationality => 'El Salvadoran', :include_in_selection => 1)
x.id = 205
x.save
x = Country.new(:code => 'SY', :name => 'Syria', :nationality => 'Syrian', :include_in_selection => 0)
x.id = 206
x.save
x = Country.new(:code => 'SZ', :name => 'Swaziland', :nationality => 'Swazi', :include_in_selection => 0)
x.id = 207
x.save
x = Country.new(:code => 'TC', :name => 'Turks and Caicos Islands', :nationality => 'Turks and Caicos Island', :include_in_selection => 0)
x.id = 208
x.save
x = Country.new(:code => 'TD', :name => 'Chad', :nationality => 'Chadian', :include_in_selection => 0)
x.id = 209
x.save
x = Country.new(:code => 'TF', :name => 'French Southern Territories', :nationality => '', :include_in_selection => 0)
x.id = 210
x.save
x = Country.new(:code => 'TG', :name => 'Togo', :nationality => 'Togolese', :include_in_selection => 1)
x.id = 211
x.save
x = Country.new(:code => 'TH', :name => 'Thailand', :nationality => 'Thai', :include_in_selection => 1)
x.id = 212
x.save
x = Country.new(:code => 'TJ', :name => 'Tajikistan', :nationality => 'Tajikistani', :include_in_selection => 0)
x.id = 213
x.save
x = Country.new(:code => 'TK', :name => 'Tokelau', :nationality => '', :include_in_selection => 0)
x.id = 214
x.save
x = Country.new(:code => 'TL', :name => 'Timor-Leste', :nationality => 'Timorese', :include_in_selection => 0)
x.id = 215
x.save
x = Country.new(:code => 'TM', :name => 'Turkmenistan', :nationality => 'Turkeman', :include_in_selection => 0)
x.id = 216
x.save
x = Country.new(:code => 'TN', :name => 'Tunisia', :nationality => 'Tunisian', :include_in_selection => 0)
x.id = 217
x.save
x = Country.new(:code => 'TO', :name => 'Tonga', :nationality => 'Tongan', :include_in_selection => 0)
x.id = 218
x.save
x = Country.new(:code => 'TR', :name => 'Turkey', :nationality => 'Turkish', :include_in_selection => 0)
x.id = 219
x.save
x = Country.new(:code => 'TT', :name => 'Trinidad and Tobago', :nationality => 'Trinidadian', :include_in_selection => 0)
x.id = 220
x.save
x = Country.new(:code => 'TV', :name => 'Tuvalu', :nationality => 'Tuvaluan', :include_in_selection => 0)
x.id = 221
x.save
x = Country.new(:code => 'TW', :name => 'Taiwan', :nationality => 'Taiwanese', :include_in_selection => 1)
x.id = 222
x.save
x = Country.new(:code => 'TZ', :name => 'Tanzania', :nationality => 'Tanzanian', :include_in_selection => 0)
x.id = 223
x.save
x = Country.new(:code => 'UA', :name => 'Ukraine', :nationality => 'Ukrainian', :include_in_selection => 1)
x.id = 224
x.save
x = Country.new(:code => 'UG', :name => 'Uganda', :nationality => 'Ugandan', :include_in_selection => 0)
x.id = 225
x.save
x = Country.new(:code => 'UM', :name => 'United States minor outlying islands', :nationality => 'American', :include_in_selection => 0)
x.id = 226
x.save
x = Country.new(:code => 'US', :name => 'United States', :nationality => 'American', :include_in_selection => 1)
x.id = 227
x.save
x = Country.new(:code => 'UY', :name => 'Uruguay', :nationality => 'Uruguayan', :include_in_selection => 0)
x.id = 228
x.save
x = Country.new(:code => 'UZ', :name => 'Uzbekistan', :nationality => 'Uzbek', :include_in_selection => 0)
x.id = 229
x.save
x = Country.new(:code => 'VA', :name => 'Vatican', :nationality => 'Vatican', :include_in_selection => 0)
x.id = 230
x.save
x = Country.new(:code => 'VC', :name => 'Saint Vincent and the Grenadines', :nationality => 'St. Vincentian', :include_in_selection => 0)
x.id = 231
x.save
x = Country.new(:code => 'VE', :name => 'Venezuela', :nationality => 'Venezuelan', :include_in_selection => 1)
x.id = 232
x.save
x = Country.new(:code => 'VG', :name => 'British Virgin Islands', :nationality => 'British Virgin Island', :include_in_selection => 1)
x.id = 233
x.save
x = Country.new(:code => 'VI', :name => 'American Virgin Islands', :nationality => 'American Virgin Island', :include_in_selection => 1)
x.id = 234
x.save
x = Country.new(:code => 'VN', :name => 'Vietnam', :nationality => 'Vietnamese', :include_in_selection => 0)
x.id = 235
x.save
x = Country.new(:code => 'VU', :name => 'Vanuatu', :nationality => 'Vanuatuan', :include_in_selection => 0)
x.id = 236
x.save
x = Country.new(:code => 'WF', :name => 'Wallis and Futuna', :nationality => 'Wallisian/Futunan', :include_in_selection => 0)
x.id = 237
x.save
x = Country.new(:code => 'WS', :name => 'Samoa', :nationality => 'Samoan', :include_in_selection => 0)
x.id = 238
x.save
x = Country.new(:code => 'YE', :name => 'Yemen', :nationality => 'Yemeni', :include_in_selection => 0)
x.id = 239
x.save
x = Country.new(:code => 'YT', :name => 'Mayotte', :nationality => 'Mahoran', :include_in_selection => 0)
x.id = 240
x.save
x = Country.new(:code => 'ZA', :name => 'South Africa', :nationality => 'South African', :include_in_selection => 1)
x.id = 241
x.save
x = Country.new(:code => 'ZM', :name => 'Zambia', :nationality => 'Zambian', :include_in_selection => 0)
x.id = 242
x.save
x = Country.new(:code => 'ZW', :name => 'Zimbabwe', :nationality => 'Zimbabwean', :include_in_selection => 0)
x.id = 243
x.save
x = Country.new(:code => 'UKI', :name => 'Northern Ireland', :nationality => 'Northern Irish', :include_in_selection => 1)
x.id = 256
x.save
x = Country.new(:code => 'UKS', :name => 'Scotland', :nationality => 'Scottish', :include_in_selection => 1)
x.id = 257
x.save
x = Country.new(:code => 'UKW', :name => 'Wales', :nationality => 'Welsh', :include_in_selection => 1)
x.id = 258
x.save
x = Country.new(:code => '??', :name => 'Not known', :nationality => 'Not known', :include_in_selection => 1)
x.id = 999999
x.save

# Seeding Groups
Group.delete_all
x = Group.new(:group_name => 'All', :abbrev => 'all', :primary => true)
x.id = 1
x.save
x = Group.new(:group_name => 'Administrators', :abbrev => 'admin', :parent_group_id => 3, :primary => true)
x.id = 2
x.save
x = Group.new(:group_name => 'Moderators', :abbrev => 'mod', :parent_group_id => 4, :primary => true)
x.id = 3
x.save
x = Group.new(:group_name => 'Members', :abbrev => 'members', :parent_group_id => 1, :primary => true)
x.id = 4
x.save



#puts "**** Seeding locations table"
Location.delete_all
x = Location.new(:name => 'Enugu'  )
x.id = 1
x.save
x = Location.new(:name => 'Aba Bible College, Abia State'  )
x.id = 5
x.save
x = Location.new(:name => 'Egbe Hospital'  )
x.id = 6
x.save
x = Location.new(:name => 'Igbaja Seminary'  )
x.id = 7
x.save
x = Location.new(:name => 'Ilorin'  )
x.id = 8
x.save
x = Location.new(:name => 'Kaiama'  )
x.id = 9
x.save
x = Location.new(:name => 'Abuja'  )
x.id = 10
x.save
x = Location.new(:name => 'Baptist Guest House Abuja'  )
x.id = 11
x.save
x = Location.new(:name => 'Gure'  )
x.id = 12
x.save
x = Location.new(:name => 'Kagoro'  )
x.id = 13
x.save
x = Location.new(:name => 'Kagoro -- Seminary'  )
x.id = 14
x.save
x = Location.new(:name => 'Adunu/ECWA/EMS'  )
x.id = 15
x.save
x = Location.new(:name => 'Samaru/ECWA Widows Sch'  )
x.id = 16
x.save
x = Location.new(:name => 'Minna'  )
x.id = 17
x.save
x = Location.new(:name => 'Ningi'  )
x.id = 18
x.save
x = Location.new(:name => 'Billiri -- ECWA Theol College'  )
x.id = 19
x.save
x = Location.new(:name => 'Kano'  )
x.id = 20
x.save
x = Location.new(:name => 'Tofa/ECWA Bible Train. Sch.'  )
x.id = 21
x.save
x = Location.new(:name => 'Jos'  )
x.id = 22
x.save
x = Location.new(:name => 'BUTH (Evangel) Hospital'  )
x.id = 23
x.save
x = Location.new(:name => 'Spring of Life'  )
x.id = 24
x.save
x = Location.new(:name => 'Gidan Bege'  )
x.id = 25
x.save
x = Location.new(:name => 'Challenge Compound'  )
x.id = 26
x.save
x = Location.new(:name => 'Jos Pharmacy Compound'  )
x.id = 27
x.save
x = Location.new(:name => 'Jos ECWA/SIM Headquarters'  )
x.id = 28
x.save
x = Location.new(:name => 'Jos Oasis Campound'  )
x.id = 29
x.save
x = Location.new(:name => 'Niger Creek Compound'  )
x.id = 30
x.save
x = Location.new(:name => 'Apollo Crescent'  )
x.id = 31
x.save
x = Location.new(:name => 'Woyke House'  )
x.id = 32
x.save
x = Location.new(:name => 'Danish Lutheran Compound'  )
x.id = 33
x.save
x = Location.new(:name => 'Hillcrest School'  )
x.id = 34
x.save
x = Location.new(:name => 'Jos CRC Mountain View'  )
x.id = 35
x.save
x = Location.new(:name => 'Jos ELM House'  )
x.id = 36
x.save
x = Location.new(:name => 'JETS'  )
x.id = 37
x.save
x = Location.new(:name => 'Word of  Life'  )
x.id = 38
x.save
x = Location.new(:name => 'Jos City Ministries'  )
x.id = 39
x.save
x = Location.new(:name => 'Miango'  )
x.id = 40
x.save
x = Location.new(:name => 'Miango MRH'  )
x.id = 41
x.save
x = Location.new(:name => 'Miango Kent Academy'  )
x.id = 42
x.save
x = Location.new(:name => 'Miango Dental Clinic'  )
x.id = 43
x.save
x = Location.new(:name => 'Karu--Seminary'  )
x.id = 44
x.save

