module EmailPhantomJob
  @queue = :pdf_email

  @options = {
    :viewport_width => 896,
    :viewport_height => 1270,
    :margin => '0cm',
    :rendering_time => 40000,
    :logfile => '~/access.log'
  }

  @output = "#{Rails.root}/public/reports/pdf"

  def self.perform(url, cookies, name, to)
    filename = "#{name.strip.tr(' ', '_')}-#{Time.now.to_i}.pdf"
    path = "#{@output}/#{filename}"
    p = Shrimp::Phantom.new(url, @options, cookies)
    fullpath = p.to_pdf(path)

    Pony.mail(:to => to,
              :from => 'axis@unhcr.org',
              :subject => name,
              :body => Quoth.get,
              :attachments => { filename => File.read(fullpath) },
              :via => :smtp,
              :via_options => {
                :address => 'smtphub.unhcr.local',
                :port => 25,
                :user_name => 'hqaxis',
                :password => ENV['EMAIL_PASSWORD'],
                :authentication => :ntml,
                :openssl_verify_mode => 'none',
              })
  end
end
