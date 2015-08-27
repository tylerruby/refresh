class StoresController < ApplicationController
  DEFAULT_RADIUS = 10 # miles

  def index
    @stores = Store.near(params[:address], DEFAULT_RADIUS)
  end

  def search_by_city
    @stores = Store.near(params[:city], DEFAULT_RADIUS)
    render :index
  end

  def search_by_coordinates
    coordinates = [params[:latitude], params[:longitude]]
    fail "Missing coordinates" if coordinates.any?(&:blank?)
    @stores = Store.near(coordinates, DEFAULT_RADIUS)
    render :index
  end
end
