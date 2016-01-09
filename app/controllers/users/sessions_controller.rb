class Users::SessionsController < Devise::SessionsController
  respond_to :html, :json

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?

    respond_to do |format|
      format.json do
        token = AuthToken.encode(user_id: resource.id)
        render json: { id: resource.id, token: token }
      end

      format.html do
        respond_with resource, location: after_sign_in_path_for(resource)
      end
    end
  end
end
