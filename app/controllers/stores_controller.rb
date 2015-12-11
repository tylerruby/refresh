class StoresController < ApplicationController
  def search_by_address
    if current_user.present?
      current_user.addresses << new_address
      current_user.update!(current_address: new_address)
    end

    session[:address_id] = new_address.id

    search_by_city
  end

  def search_by_city
    @city = city

    if @city == 'Atlanta'
      redirect_to store_path(SelectNextStore.new(Store.all).select)
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
        city: City.find_or_create_by(name: city)
      )
    end
end
