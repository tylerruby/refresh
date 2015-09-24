class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

    def cart
      @cart = Cart.exists?(@cart.try(:id)) && @cart  \
              || Cart.find_by(id: session[:cart_id]) \
              || Cart.create!
      session[:cart_id] = @cart.id
      @cart
    end
end
