class StoresController < ApplicationController
  def search_by_address
    current_user.addresses << new_address if current_user.present?

    session[:address_id] = new_address.id

    search_by_city
  end

  def search_by_city
    @city = city
    @stores = searcher.all

    render :index
  end

  def show
    @store = searcher.find(params[:id])
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
      @new_address ||= Address.create(address: params[:address], city: City.find_by(name: city))
    end
end
