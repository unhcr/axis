class SessionsController < Devise::SessionsController

  def create
    if params[:user] && params[:user][:login] == ENV['GUEST_USER'] &&
        User.where(:login => ENV['GUEST_USER']).first

      sign_in :user, User.where(:login => ENV['GUEST_USER']).first
      return render :json => { :success => true }
    end

    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    return sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    return render :json => { :success => true }
  end

  def failure
    return render :json => {:success => false, :errors => ["Login failed."]}
  end
end
