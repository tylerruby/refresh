class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_address, :coordinates, :cart, :cart_items

  protected

    def cart
      @cart = Cart.exists?(@cart.try(:id)) && @cart  \
              || current_user && current_user.cart   \
              || Cart.find_by(id: session[:cart_id]) \
              || Cart.create!(user: current_user)
      session[:cart_id] = @cart.id
      @cart
    end

    def cart_items
      @cart_items ||= cart.shopping_cart_items.order(:created_at)
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

    def current_user
      begin
        @current_user ||= warden.authenticate(:scope => :user) || user_from_token
      rescue JWT::DecodeError
        nil
      end
    end

    def authenticate_api!
      head :unauthorized unless current_user
    end

    def token_payload
      AuthToken.decode(token)
    end

    def token
      authorization = request.headers['Authorization']
      return '' if authorization.blank?
      authorization.split(' ').last
    end

    def user_from_token
      User.find(token_payload['user_id'])
    end
end
