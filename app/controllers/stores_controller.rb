class StoresController < ApplicationController
  def search_by_address
    address = Geocoder.search(params[:address]).first
    @city = address.city
    @stores = Store.by_city(@city).order_by_distance(address.coordinates)
    render :index
  end

  def search_by_city
    @city = params[:city]
    @stores = Store.by_city(params[:city])
    render :index
  end
end
