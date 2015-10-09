class ClothesController < ApplicationController
  impressionist only: [:show]

  def index
    @clothes = cloth_searcher.clothes
    @sizes = cloth_searcher.sizes
    @male_categories = Category.where(male: true)
    @female_categories = Category.where(female: true)
    render layout: false
  end

  def show
    render nothing: true
  end

  private

    def cloth_searcher
      ClothSearcher.new(params.merge(stores: store_searcher.available_for_delivery))
    end

    def store_searcher
      StoreSearcher.new(city: params[:city], coordinates: session[:coordinates])
    end
end
