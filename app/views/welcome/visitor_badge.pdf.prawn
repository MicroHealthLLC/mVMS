prawn_document(:page_layout => :landscape) do |pdf|
    data = StringIO.new( Base64.decode64(@visitor.avatar.sub('data:image/jpeg;base64', '') ))

    logo_table= pdf.make_table([ [
                                 { :image=> data, image_width: 300, image_height: 520   }
                                         ]],
                                       :column_widths => [310],  :cell_style=> {
                    width: 310,
                    font_size: 20,
                    align: :center,

                })
                header = pdf.make_table([["<b>MicroHealth, LLC</b>"]],
                :cell_style=> { size: 50 , :inline_format=> true, align: :center,    width: 450, borders: [:bottom] })



 date_creation_table= pdf.make_table([[header],
 ["Name: #{@visitor.name}"],
 ["Destination: #{@visitor.last_visit.person.try(:name)}"],
 ["Date: #{@visitor.last_visit.sign_in_date.strftime('%d, %B %Y')}"],
 ["Time: #{@visitor.last_visit.sign_in_date.strftime('%I:%M %p')}"],

  ],
                                                :column_widths => [450], :cell_style=> {
                    width: 450,
                    size: 47,
                    align: :left,
                    font_style: :italic,
                    borders: [],
                    padding: [24,0,0,30]
                })



     pdf.table([
                              [
                                  logo_table,
                                  date_creation_table

                              ]
                          ],
                          :column_widths => [300, 460],
                          :cell_style=> {
                              align: :center,
borders: []
                          })
end