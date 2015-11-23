class StoresController < ApplicationController
  def search_by_address
    current_user.addresses << new_address if current_user.present?

    session[:address_id] = new_address.id

    search_by_city
  end

  def search_by_city
    @city = city
    @stores = searcher.available_for_delivery

    if @stores.any?
      # For now we are working with one store per day's period (morning, afternoon etc)
      redirect_to store_path(@stores.first)
    else
      render :index
    end
  end

  def show
    @store = searcher.find(params[:id])
    @available_products = @store.products.available
  end

  private

    def searcher
      StoreSearcher.new(city: params[:city], coordinates: coordinates)
    end

    def city
      params[:city].titleize
    end

    # TODO: Find city in a more secure way, probably with friendly_id
    def new_address
      scope = current_user && current_user.addresses || Address
      @new_address ||= scope.find_or_create_by(
        address: params[:address],
        city: City.find_by(name: city)
      )
    end
end
