require 'rails_helper'

RSpec.describe ClothesController, type: :controller do

  describe "GET #index" do
    let(:chain) { create(:chain, stores: [create(:store)]) }

    def do_action
      get :index, search_parameters
    end

    before do
      session[:coordinates] = ["40.7143528", "-74.0059731"]

      Geocoder::Lookup::Test.add_stub("4th Av., Augusta, GA", [
        {
          'latitude'     => 40.7143528,
          'longitude'    => -74.0059731,
          'address'      => '4th Av., Augusta, GA',
          'state'        => 'Georgia',
          'state_code'   => 'GA',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ])
    end

    describe "categories" do
      let(:search_parameters) do
        {}
      end

      it "returns all the categories separated by gender" do
        female_category = create(:category, male: false, female: true)
        male_category = create(:category, male: true, female: false)
        unisex_category = create(:category, male: true, female: true)
        do_action
        expect(assigns[:female_categories]).to eq [female_category, unisex_category]
        expect(assigns[:male_categories]).to eq [male_category, unisex_category]
      end

      it "assigns a non-persisted category" do
        do_action
        category = assigns[:category]
        expect(category).to be_a Category
        expect(category).not_to be_persisted
      end
    end

    describe "without any filter" do
      let!(:first_cloth) { create(:cloth, chain: chain) }
      let!(:second_cloth) { create(:cloth, chain: chain) }

      let(:search_parameters) do
        {}
      end

      it "returns all the clothes" do
        do_action
        expect(assigns[:clothes]).to match_array [first_cloth, second_cloth]
      end

      it "doesn't return sizes" do
        do_action
        expect(assigns[:sizes]).to eq []
      end
    end

    describe "filtering by city" do
      let!(:first_store) { create(:store, city: 'Augusta') }
      let!(:first_cloth) { create(:cloth, chain: first_store.chain) }

      let!(:second_store) { create(:store, city: 'Augusta') }
      let!(:second_cloth) { create(:cloth, chain: second_store.chain) }

      let!(:store_in_another_city) { create(:store, city: 'Atlanta') }
      let!(:cloth_from_store_in_another_city) { create(:cloth, chain: store_in_another_city.chain) }

      let(:search_parameters) do
        {
          city: 'augusta'
        }
      end

      it "orders clothes by views" do
        Impression.create!(impressionable: second_cloth)
        do_action
        expect(assigns[:clothes]).to eq [second_cloth, first_cloth]
      end

      it "orders clothes by views in the last week" do
        2.times { Impression.create!(impressionable: first_cloth, created_at: 2.weeks.ago) }
        Impression.create!(impressionable: second_cloth)
        do_action
        expect(assigns[:clothes]).to eq [second_cloth, first_cloth]
      end

      it "shows only clothes from stores available for delivery" do
        session[:coordinates] = ["0", "0"]
        do_action
        expect(assigns[:clothes]).to eq []
      end

      it "sets stores for clothes to create modals" do
        do_action
        expect(assigns[:clothes][0].store).to eq second_store
        expect(assigns[:clothes][1].store).to eq first_store
      end
    end

    describe "filtering by chain ignores distance" do
      let(:chain) { create(:chain) }
      let!(:cloth) { create(:cloth, chain: chain) }
      let!(:another_chain) { create(:chain, stores: [create(:store)]) }
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
      let!(:cloth) { create(:cloth, category: category, chain: chain) }
      let!(:cloth_variant) { create(:cloth_variant, cloth: cloth, size: 'M') }
      let!(:cloth_from_another_category) { create(:cloth, chain: chain) }

      let(:search_parameters) do
        {
          category_id: category.id
        }
      end

      it "assigns the category" do
        do_action
        expect(assigns[:category]).to eq category
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
        let!(:another_cloth) { create(:cloth, category: category, chain: chain) }
        let!(:cloth_variant_from_another_size) { create(:cloth_variant, cloth: cloth, size: 'S') }

        let(:search_parameters) do
          {
            category_id: category.id,
            size: 'M'
          }
        end

        it "assigns the category" do
          do_action
          expect(assigns[:category]).to eq category
        end

        it "assigns the size" do
          do_action
          expect(assigns[:size]).to eq 'M'
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
      let!(:cloth) { create(:cloth, price: 30, chain: chain) }
      let!(:expensive_cloth) { create(:cloth, price: 50, chain: chain) }

      let(:search_parameters) do
        {
          max_price: 49
        }
      end

      it "assigns the max price" do
        do_action
        expect(assigns[:max_price]).to eq "49"
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
