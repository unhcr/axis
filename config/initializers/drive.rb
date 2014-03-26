config = YAML::load(File.open("#{Rails.root}/config/drive.yml"))[Rails.env]
ENV['DRIVE_USERNAME'] = config['username']
ENV['DRIVE_PASSWORD'] = config['password']
ENV['DRIVE_SHEET_KEY'] = config['key']
