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

    next_store = SelectNextStore.new(Store.all).select

    respond_to do |format|
      format.json do
        render json: { store: { id: next_store.id } }
      end

      format.html do
        if @city == 'Atlanta'
          redirect_to store_path(next_store)
        else
          render :index
        end
      end
    end
  end

  def show
    @store = searcher.find(params[:id])
    @available_products = @store.products
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
