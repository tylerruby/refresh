require 'rails_helper'

RSpec.describe ClothesController, type: :controller do

  describe "GET #index" do
    def do_action
      get :index, search_parameters
    end

    describe "without any filter" do
      let!(:cloth1) { create(:cloth) }
      let!(:cloth2) { create(:cloth) }

      let(:search_parameters) do
        {}
      end

      it "returns all the clothes" do
        do_action
        expect(assigns[:clothes]).to eq [cloth1, cloth2]
      end

      it "doesn't return sizes" do
        do_action
        expect(assigns[:sizes]).to eq []
      end
    end

    describe "filtering by chain" do
      let!(:chain) { create(:chain) }
      let!(:cloth) { create(:cloth, chain: chain) }
      let!(:cloth_from_another_chain) { create(:cloth) }

      let(:search_parameters) do
        {
          chain_id: chain.id
        }
      end

      it "returns only clothes from that chain" do
        do_action
        expect(assigns[:clothes]).to eq [cloth]
      end

      it "doesn't return sizes" do
        do_action
        expect(assigns[:sizes]).to eq []
      end
    end

    describe "filtering by category" do
      let!(:category) { create(:category) }
      let!(:cloth) { create(:cloth, category: category) }
      let!(:cloth_variant) { create(:cloth_variant, cloth: cloth, size: 'M') }
      let!(:cloth_from_another_category) { create(:cloth) }

      let(:search_parameters) do
        {
          category_id: category.id
        }
      end

      it "returns only clothes from that category" do
        do_action
        expect(assigns[:clothes]).to eq [cloth]
      end

      it "returns available sizes without repetition" do
        create(:cloth_variant, size: 'M', cloth: create(:cloth, category: category))
        do_action
        expect(assigns[:sizes]).to eq ['M']
      end

      describe "filtering by size" do
        let!(:another_cloth) { create(:cloth, category: category) }
        let!(:cloth_variant_from_another_size) { create(:cloth_variant, cloth: cloth, size: 'S') }

        let(:search_parameters) do
          {
            category_id: category.id,
            size: 'M'
          }
        end

        it "returns only clothes from that category and size" do
          do_action
          expect(assigns[:clothes]).to eq [cloth]
        end

        it "doesn't return sizes" do
          do_action
          expect(assigns[:sizes]).to eq []
        end
      end
    end

    describe "filtering by price" do
      let!(:cloth) { create(:cloth, price: 30) }
      let!(:expensive_cloth) { create(:cloth, price: 50) }

      let(:search_parameters) do
        {
          max_price: 49
        }
      end

      it "returns only clothes up to that price" do
        do_action
        expect(assigns[:clothes]).to eq [cloth]
      end

      it "doesn't return sizes" do
        do_action
        expect(assigns[:sizes]).to eq []
      end
    end
  end

  describe "GET #show" do
    let(:cloth) { create(:cloth) }

    def do_action
      get :show, id: cloth
    end

    it "returns nothing" do
      do_action
      expect(response).to have_http_status(:success)
      expect(response.body).to be_empty
    end

    it "tracks the view" do
      expect { do_action }.to change { cloth.impressionist_count }.by(1)
    end
  end
end
