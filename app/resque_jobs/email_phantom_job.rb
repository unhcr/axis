# This background job is responsible for emailing a PDF version of a figure.
module EmailPhantomJob
  @queue = :pdf_email

  # Options for Shrimp (https://github.com/adjust/shrimp) the logfile is a custom option added in a fork
  # here: https://github.com/benrudolph/shrimp
  @options = {
    :viewport_width => 896,
    :viewport_height => 1270,
    :margin => '0cm',
    :rendering_time => 40000,
    :logfile => 'log/pdf.log'
  }

  # The folder where the PDFs will be stored
  @output = "#{Rails.root}/public/reports/pdf"

  # @param url - the url that Shrimp should use to convert to a PDF
  # @param cookies - the cookies that are set for the user. this is important for auth reasons
  # @param name - the name of the pdf
  # @param to - the email address to send to
  def self.perform(url, cookies, name, to)
    begin
      Rails.logger.info "XXXX: Starting pdf generation..."

      filename = "#{name.strip.tr(' ', '_')}-#{Time.now.to_i}.pdf"

      path = "#{@output}/#{filename}"
      p = Shrimp::Phantom.new(url, @options, cookies)
      fullpath = p.to_pdf(path)

      Rails.logger.info "XXXX: pdf generated: #{fullpath}"

      Pony.mail(:to => to,
                :from => 'axis@unhcr.org',
                :subject => name,
                :body => Quoth.get,
                :attachments => { filename => File.read(fullpath) },
                :via => :smtp,
                :via_options => {
                  :address => 'smtprelay.unhcr.local',
                  :port => 25,
                  :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
                })

      Rails.logger.info "XXXX: email sent to: #{to}"
    rescue e
      Rails.logger.info "XXXX Error: pdf email failed: #{e}"
    end
  end
end
