class StoresController < ApplicationController
  def search_by_address
    session[:coordinates] = [params[:latitude], params[:longitude]]

    @city = city
    @stores = stores_in(@city)
    render :index
  end

  def search_by_city
    @city = city
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

  def city
    params[:city].titleize
  end
end
