class ExportModule < ActiveRecord::Base
  attr_accessible :figure_config, :description, :include_explaination, :include_parameter_list, :state, :title, :figure_type

  serialize :state, Hash
  serialize :figure_config, Hash
  serialize :figure_type, Hash

  belongs_to :user

  def email(host, cookies)
    url = "#{host}/export_modules/#{self.id}/pdf"
    Resque.enqueue(EmailPhantomJob, url, cookies, "#{self.title}.pdf")
  end
end
