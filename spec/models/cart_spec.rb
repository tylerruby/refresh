require 'rails_helper'

RSpec.describe Cart, type: :model do
  it "describes one item" do
    cart = Cart.create!
    cart.delivery_time = 1
    cloth_instance = create(:cloth_instance)
    cart.add(cloth_instance, 10.to_money, 1)
    expect(cart.description).to eq '1 cloth ($19.99)'
  end

  it "describes more than one item" do
    cart = Cart.create!
    cart.delivery_time = 1
    cloth_instance = create(:cloth_instance)
    cart.add(cloth_instance, 10.to_money, 2)
    expect(cart.description).to eq '2 clothes ($29.99)'
  end

  it "calculates #shipping_cost with #shipping_cost_for" do
    cart = Cart.new
    cart.delivery_time = 1
    expect(cart).to receive(:shipping_cost_for).with(1)
    cart.shipping_cost
  end

  describe "#shipping_cost_for" do
    let(:cart) { Cart.create! }

    it "only allows 1 or 2 for delivery time" do
      expect { cart.shipping_cost_for(1) }.not_to raise_error
      expect { cart.shipping_cost_for(2) }.not_to raise_error
      expect { cart.shipping_cost_for(3) }.to raise_error(Cart::InvalidDeliveryTime)
      expect { cart.shipping_cost_for(0) }.to raise_error(Cart::InvalidDeliveryTime)
    end

    context "1 store" do
      let(:cloth_from_some_store) { create(:cloth_variant) }

      context "1 hour" do
        let(:delivery_time) { 1 }

        context "over $35.00" do
          before do
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_some_store), 100)
          end

          it { expect(cart.shipping_cost_for(delivery_time)).to eq '$5.99'.to_money }
        end

        context "under $35.00" do
          before do
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_some_store), 10)
          end

          it { expect(cart.shipping_cost_for(delivery_time)).to eq '$9.99'.to_money }
        end
      end

      context "2 hours" do
        let(:delivery_time) { 2 }

        context "over $35.00" do
          before do
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_some_store), 100)
          end

          it { expect(cart.shipping_cost_for(delivery_time)).to eq '$3.99'.to_money }
        end

        context "under $35.00" do
          before do
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_some_store), 10)
          end

          it { expect(cart.shipping_cost_for(delivery_time)).to eq '$7.99'.to_money }
        end
      end
    end

    context "3 stores" do
      let(:cloth_from_first_store) { create(:cloth_variant) }
      let(:cloth_from_second_store) { create(:cloth_variant) }
      let(:cloth_from_third_store) { create(:cloth_variant) }

      context "1 hour" do
        let(:delivery_time) { 1 }

        context "over $35.00" do
          before do
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_first_store), 98)
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_second_store), 1)
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_third_store), 1)
          end

          it { expect(cart.shipping_cost_for(delivery_time)).to eq '$11.99'.to_money }
        end

        context "under $35.00" do
          before do
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_first_store), 8)
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_second_store), 1)
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_third_store), 1)
          end

          it { expect(cart.shipping_cost_for(delivery_time)).to eq '$15.99'.to_money }
        end
      end

      context "2 hours" do
        let(:delivery_time) { 2 }

        context "over $35.00" do
          before do
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_first_store), 98)
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_second_store), 1)
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_third_store), 1)
          end

          it { expect(cart.shipping_cost_for(delivery_time)).to eq '$9.99'.to_money }
        end

        context "under $35.00" do
          before do
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_first_store), 8)
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_second_store), 1)
            cart.add(create(:cloth_instance, cloth_variant: cloth_from_third_store), 1)
          end

          it { expect(cart.shipping_cost_for(delivery_time)).to eq '$13.99'.to_money }
        end
      end
    end
  end
end
