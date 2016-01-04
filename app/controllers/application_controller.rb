class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_address, :coordinates, :cart

  protected

    def cart
      @cart = Cart.exists?(@cart.try(:id)) && @cart  \
              || Cart.find_by(id: session[:cart_id]) \
              || Cart.create!
      session[:cart_id] = @cart.id
      @cart
    end

    def current_address
      if current_user
        current_user.current_address
      else
        Address.find_by(id: session[:address_id])
      end
    end

    def coordinates
      current_address && current_address.coordinates
    end

    def authenticate!
      if request.format.json?
        authenticate_api!
      else
        authenticate_user!
      end
    end

    def authenticate_api!
      head :unauthorized if request.headers['Authorization'].nil? ||
        !AuthToken.decode(request.headers['Authorization'].split(' ').last)
    end
end
