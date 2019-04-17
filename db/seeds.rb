# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(full_name: 'admin', email: 'admin@example.com', password: 'admin@2018', admin: true, state: true)

if AdminLoginPage.count == 0
  AdminLoginPage.create(
    section_1_image: '',
    section_1_body: 'MicroHealth Visitor Management System (mVMS) is the recording and collection of visitor data — manually or through automation — for the purpose of knowing who is in ​​a facility, who they are visiting and how long they spent there.
          .',
    section_1_file: '',
    section_2_image: '',
    section_3_title: 'About MicroHealth Visitor Management System?',
    section_3_body: '  MicroHealth Visitor Management System (mVMS)  management system maximizes your front desk’s efficiency by allowing the receptionist to work on other important projects while your visitors sign themselves in with the Sign in.',
    section_4_title: 'Made for Government Contractors',
    section_4_body: 'Visitor management software electronically monitors and records information about visitors and employees of a business or public building. The software also documents and gathers information about a visitor’s whereabouts in the facility.'
  )
end
