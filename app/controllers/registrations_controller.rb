class RegistrationsController < Devise::RegistrationsController

  def create
    build_resource

    notice = nil

    if resource.save
      if resource.active_for_authentication?
        notice = :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        return render :json => { :success => true, :notice => notice }
      else
        notice  = :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        return render :json => { :success => true, :notice => notice }
      end
    else
      clean_up_passwords resource
      return render :json => {:success => false}
    end
  end

  # Signs in a user on sign up
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

end
