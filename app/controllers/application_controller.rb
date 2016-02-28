class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_address, :current_region, :coordinates, :cart, :cart_items, :cart_items_by_date

  protected

    def cart
      @cart = Cart.exists?(@cart.try(:id)) && @cart \
              || current_user.cart                  \
              || Cart.create!
      current_user.update!(cart: @cart)
      @cart
    end

    def cart_items
      @cart_items ||= cart.shopping_cart_items.order(:created_at)
    end

    def cart_items_by_date
      cart_items.group_by { |cart_item| cart_item.item.menu.date  }
    end

    def current_address
      if current_user
        current_user.current_address
      else
        Address.find_by(id: session[:address_id])
      end
    end

    def current_region
      SelectRegion.new(current_address).region
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
        @current_user = GuestUser.new(session)
      end
    end

    def user_signed_in?
      current_user.persisted?
    end

    def authenticate_api!
      head :unauthorized unless user_signed_in?
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
