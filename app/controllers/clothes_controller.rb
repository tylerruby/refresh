class ClothesController < ApplicationController
  impressionist only: [:show]

  def index
    searcher = ClothSearcher.new(params)
    @clothes = searcher.clothes
    @sizes = searcher.sizes

    render nothing: true
  end

  def show
    render nothing: true
  end
end
