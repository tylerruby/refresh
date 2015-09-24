class DeleteOldOrdersAndProductVariants < ActiveRecord::Migration
  def change
    Cart.destroy_all
    CartItem.destroy_all
    ClothInstance.destroy_all
    Order.destroy_all
  end
end
