class MenusController < ApplicationController
  def show
    @menu = Menu.find_by!(date: params[:date] || Date.current)
  end
end
