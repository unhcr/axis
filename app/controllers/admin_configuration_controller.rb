class AdminConfigurationController < ApplicationController

  before_filter :authenticate_user!

  def edit
    render_403 and return unless current_user.admin
    @configuration = AdminConfiguration.first
    render :edit
  end

  def update
    render_403 and return unless current_user.admin
    @configuration = AdminConfiguration.first
    @configuration.update_attributes params[:admin_configuration]

    render :show
  end

  def show
    render_403 and return unless current_user.admin
    @configuration = AdminConfiguration.first

    @last_focus_db_synch = FetchMonitor.first.updated_at if FetchMonitor.first

    render :show
  end

  def download_users
    # Get the user list
    users = AdminConfiguration.first.users

    # Create the workbook
    p = Axlsx::Package.new
    workbook = p.workbook

    workbook.add_worksheet(:name => 'Users') do |users_ws|
      # Headings
      users_ws.add_row ['Users'], :sz => 24
      users_ws.merge_cells('A1:C1')

      # Content
      users.each do |user|
        users_ws.add_row [user.login]
      end
    end

    # Send back
    send_data p.to_stream.read,
              :filename => "users--#{Time.now}.xls",
              :disposition => 'inline',
              :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end
end
