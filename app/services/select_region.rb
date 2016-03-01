class SelectRegion
  RADIUS = 10 #miles

  def initialize(address, regions = Region.all)
    self.address = address
    self.regions = regions
  end

  def region
    regions.detect do |region|
      region.address.distance_from(address.coordinates) <= RADIUS
    end
  end

  private

    attr_accessor :address, :regions
end
