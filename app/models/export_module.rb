# The ExportModule is responsible of maintaining the state of a figure when it is exported as a pdf.
# It holds 3 fields that will store the Json hash of the figure it exporting.

class ExportModule < ActiveRecord::Base
  attr_accessible :figure_config, :description, :include_explaination, :include_parameter_list, :state, :title, :figure_type

  serialize :state, Hash
  serialize :figure_config, Hash
  serialize :figure_type, Hash

  belongs_to :user

  def email(host, cookies, to)
    url = "#{host}/export_modules/#{self.id}/pdf"
    name = self.title.empty? ? 'dummy' : self.title

Rails.logger.info "XXXXX URL: #{url} - #{cookies} - #{name} - #{to}"
    Resque.enqueue(EmailPhantomJob, url, cookies, name, to)
  end
end
