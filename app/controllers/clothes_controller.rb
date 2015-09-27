class ClothesController < ApplicationController
  impressionist only: [:show]

  def show
    render nothing: true
  end
end
