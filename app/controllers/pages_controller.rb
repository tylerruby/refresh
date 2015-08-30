class PagesController < ApplicationController
  def home
  end

  def store
  end

  def city
  end

  def notifications
  end

  def landing
    @cities = Store.select(:city).distinct.map(&:city)
  end
end
