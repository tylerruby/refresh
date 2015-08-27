class StoresController < ApplicationController
  def index
    @stores = Store.near(params[:address])
  end

  def search_by_city
    @stores = Store.near(params[:city])
    render :index
  end

  def search_by_coordinates
    coordinates = [params[:latitude], params[:longitude]]
    fail "Missing coordinates" if coordinates.any?(&:blank?)
    @stores = Store.near(coordinates)
    render :index
  end
end
