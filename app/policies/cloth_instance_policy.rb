class ClothInstancePolicy
  def initialize(user, cloth_instance)
    @user = user
    @cloth_instance = cloth_instance
  end

  def add?
    @cloth_instance.store.available_for_delivery?
  end
end
