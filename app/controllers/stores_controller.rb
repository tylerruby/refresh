class StoresController < ApplicationController
  def search_by_address
    address = Geocoder.search(params[:address]).first
    session[:coordinates] = address.coordinates
    @city = address.city
    @stores = stores
    render :index
  end

  def search_by_city
    @city = params[:city].titleize
    @stores = stores
    render :index
  end

  def show
    @store = Store.friendly.find(params[:id])
  end

  private

  def stores
    if session[:coordinates]
      Store.by_city(@city).order_by_distance(session[:coordinates])
    else
      Store.by_city(params[:city])
    end
  end
end
