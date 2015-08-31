class StoresController < ApplicationController
  def search_by_address
    address = Geocoder.search(params[:address]).first
    session[:coordinates] = address.coordinates
    @city = address.city
    @stores = stores_in(@city)
    render :index
  end

  def search_by_city
    @city = params[:city].titleize
    @stores = stores_in(@city)
    render :index
  end

  def show
    @store = Store.all.scoping do
      if session[:coordinates]
        Store.order_by_distance(session[:coordinates])
      else
        Store.all
      end
    end.friendly.find(params[:id])
  end

  private

  def stores_in(city)
    if session[:coordinates]
      Store.by_city(city).order_by_distance(session[:coordinates])
    else
      Store.by_city(city)
    end
  end
end
