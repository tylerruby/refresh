class StoresController < ApplicationController
  def search_by_address
    session[:coordinates] = [params[:latitude], params[:longitude]]

    search_by_city
  end

  def search_by_city
    @city = city
    @stores = searcher.all

    render :index
  end

  def show
    @store = searcher.find(params[:id])
    @clothes = @store.clothes.sort_by do |cloth|
                 cloth.last_week_views
               end.reverse!
  end

  private

    def searcher
      StoreSearcher.new(city: params[:city], coordinates: session[:coordinates])
    end

    def city
      params[:city].titleize
    end
end
