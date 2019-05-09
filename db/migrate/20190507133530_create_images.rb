class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      d = File.join(Rails.root, 'public', 'visitor_images')
      unless File.exist? d
        FileUtils.mkdir(d)
      end
      Visitor.all.each do |visitor|
        visitor.save_image_avatar
      end
    end
  end
end
