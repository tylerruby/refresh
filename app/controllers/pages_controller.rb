class PagesController < ApplicationController
  def home
  end

  def store
  end

  def notifications
  end

  def landing
    @cities = Store.select(:city).distinct.map(&:city)
  end

  def profile
  end

  def login
  end

  def help
  end

  def about
  end

  def terms
  end

  def blog
  end

  def privacy
  end
  
  def contact
  end

  def partners
  end

end
