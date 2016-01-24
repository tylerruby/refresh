class RestaurantsController < ApplicationController
  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(params[:contact])
    @restaurant.request = request
    if @restaurant.deliver
      flash.now[:notice] = 'Thank you for your partnership inquiry. We will be in touch soon!'
    else
      flash.now[:error] = 'Cannot send message.'
      render :new
    end
  end
end