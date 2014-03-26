filename = "#{Rails.root}/config/drive.yml"
if File.exists? filename
  config = YAML::load(File.open(filename))[Rails.env]
  ENV['DRIVE_USERNAME'] = config['username']
  ENV['DRIVE_PASSWORD'] = config['password']
  ENV['DRIVE_SHEET_KEY'] = config['key']
end
