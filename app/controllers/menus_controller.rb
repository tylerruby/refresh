class MenusController < ApplicationController
  def show
    @menu = Menu.find_by!(
      date: params[:date] || Date.current,
      region: SelectRegion.new(current_address).region
    )
    @menu_dates = SelectMenuDates.new(Date.current).dates
  end
end
