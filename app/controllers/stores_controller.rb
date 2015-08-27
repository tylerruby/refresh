class StoresController < ApplicationController
  def search_by_city
    @stores = Store.near(params[:city])
    render :index
  end

  def search_by_coordinates
    @stores = Store.near([params[:latitude], params[:longitude]])
    render :index
  end
end
