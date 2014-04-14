module EmailPhantomJob
  @queue = :pdf_email

  @options = {
    :viewport_width => 896,
    :viewport_height => 1270,
    :margin => '0cm',
    :rendering_time => 11000,
    :logfile => '~/access.log'
  }

  @output = "#{Rails.root}/public/reports/pdf"

  def self.perform(url, cookies, filename)
    path = "#{@output}/#{filename}"
    p = Shrimp::Phantom.new(url, @options, cookies)
    fullpath = p.to_pdf(path)

    Pony.mail(:to => 'rudolph@unhcr.org',
              :from => 'rudolphben@gmail.com',
              :subject => 'Your report',
              :body => 'Hello there.',
              :attachments => { filename => File.read(fullpath) })
  end
end

