class ClothesController < ApplicationController
  impressionist actions: [:show]

  def index
    @genders = %w(male female)
    @clothes = cloth_searcher.clothes
    @sizes = cloth_searcher.sizes
    @store = cloth_searcher.store
    @categories = case gender
                  when 'male' then Category.where(male: true)
                  when 'female' then Category.where(female: true)
                  else []
                  end

    @category = Category.find_or_initialize_by(id: params[:category_id])
    @size = params[:size]
    @max_price = params[:max_price]
    render layout: false
  end

  def show
    render nothing: true
  end

  private

    def cloth_searcher
      @cloth_searcher ||= ClothSearcher.new(
        params.merge(gender: gender, stores: store_searcher.available_for_delivery)
      )
    end

    def store_searcher
      @store_searcher ||= StoreSearcher.new(
        city: params[:city],
        coordinates: session[:coordinates]
      )
    end

    def gender
      @gender ||= params[:gender] || 'male'
    end
end
