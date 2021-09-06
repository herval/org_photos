# before using:
#
# brew install exiftool
# gem install exiftool

require "exiftool"
require "FileUtils"

@kinds = ["*.jpg", "*.png", "*.mov", "*.mp4", "*.gif", "*.JPG", "*.PNG", "*.jpeg", "*.GIF", "*.heic", "*.HEIC", "*.cr2", "*.cr3", "*.orf"]

def move(ph, folder)
  to = folder + "/" + ph
  puts to
  if File.exists?(to)
    p "File already exists? #{to}"
  else
    FileUtils.move(ph, to)
  end

  meta_file = ph.gsub(/\.[\w]+$/, ".xmp") # metadata file w/ same name
  meta_to = folder + "/" + meta_file
  if File.exists?(meta_file) && !File.exists?(meta_to)
    p "Moving xmp metadata file for #{ph}"
    FileUtils.move(meta_file, meta_to)
  end
end


# move based on filename
def move_by_filename()
  exp = /\d{4}-\d{2}-\d{2}*/

  photos = @kinds.map { |k| Dir[k] }.flatten.select { |p| exp.match(p) }

  folders = photos.map { |ph| exp.match(ph)[0] + "/" }.uniq

  folders.each { |ph| FileUtils.mkdir(ph) rescue nil }

  photos.each do |ph|
    folder = exp.match(ph)[0]
    move(ph, folder)
  end
end


# move based on file creation date
def move_by_exif_date()
  photos = @kinds.map { |k| Dir[k] }.flatten

  photos.each do |p|
    exif = Exiftool.new(p).to_hash

    created = exif[:date_time_original_civil]
    if created
      folder = created.strftime("%Y-%m-%d")
      FileUtils.mkdir(folder) rescue nil

      move(p, folder)
    end
  end
end


move_by_filename()
move_by_exif_date()