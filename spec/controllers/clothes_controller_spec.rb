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

    describe "without any filter" do
      let!(:category) { create(:category, male: true) }
      let!(:first_cloth) { create(:cloth, chain: chain, category: category) }
      let!(:second_cloth) { create(:cloth, chain: chain, category: category) }

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

      it "assigns a category even if none is selected" do
        do_action
        category = assigns[:category]
        expect(category).to be_a Category
        expect(category).not_to be_persisted
      end

      it "assigns a default gender" do
        do_action
        expect(assigns[:gender]).to eq 'male'
      end

      it "return categories for the default gender" do
        do_action
        expect(assigns[:categories]).to eq [category]
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

    describe "filtering by gender" do
      let!(:female_category) { create(:category, male: false, female: true) }
      let!(:male_category) { create(:category, male: true, female: false) }
      let!(:unisex_category) { create(:category, male: true, female: true) }

      let!(:male_cloth) do
        create(:cloth, category: male_category, gender: 'male', chain: chain)
      end
      let!(:female_cloth) do
        create(:cloth, category: female_category, gender: 'female', chain: chain)
      end
      let!(:unisex_cloth) do
        create(:cloth, category: unisex_category, gender: 'unisex', chain: chain)
      end
      let!(:male_cloth_from_unisex_category) do
        create(:cloth, category: unisex_category, gender: 'male', chain: chain)
      end
      let!(:female_cloth_from_unisex_category) do
        create(:cloth, category: unisex_category, gender: 'female', chain: chain)
      end

      let(:search_parameters) do
        {}
      end

      it "always shows all genders" do
        do_action
        expect(assigns[:genders]).to eq %w(male female)
      end

      context "selecting male" do
        let(:search_parameters) do
          {
            gender: 'male'
          }
        end

        before { do_action }
        it { expect(assigns[:gender]).to eq 'male' }
        it { expect(assigns[:categories]).to eq [male_category, unisex_category] }
        it do
          expect(assigns[:clothes]).to match_array [
            male_cloth,
            unisex_cloth,
            male_cloth_from_unisex_category
          ]
        end
      end

      context "selecting female" do
        let(:search_parameters) do
          {
            gender: 'female'
          }
        end

        before { do_action }

        it { expect(assigns[:gender]).to eq 'female' }
        it { expect(assigns[:categories]).to eq [female_category, unisex_category] }
        it do
          expect(assigns[:clothes]).to match_array [
            female_cloth,
            unisex_cloth,
            female_cloth_from_unisex_category
          ]
        end
      end

      context "selecting invalid gender" do
        let(:search_parameters) do
          {
            gender: 'invalid gender'
          }
        end

        before { do_action }

        it { expect(assigns[:gender]).to eq 'invalid gender' }
        it { expect(assigns[:categories]).to eq [] }
        it { expect(assigns[:clothes]).to eq [] }
      end

      describe "filtering by category" do
        let!(:cloth_variant) { create(:cloth_variant, cloth: male_cloth, size: 'M') }
        let!(:cloth_from_another_category) { create(:cloth, chain: chain) }

        let(:search_parameters) do
          {
            gender: 'male',
            category_id: male_category.id
          }
        end

        it "assigns the category" do
          do_action
          expect(assigns[:category]).to eq male_category
        end

        it "returns only clothes from that category" do
          do_action
          expect(assigns[:clothes]).to eq [male_cloth]
        end

        it "returns available sizes without repetition" do
          create(:cloth_variant, size: 'M', cloth: create(:cloth, category: male_category))
          do_action
          expect(assigns[:sizes]).to eq ['M']
        end

        describe "filtering by size" do
          let!(:another_cloth_from_same_category) do
            create(:cloth, category: male_cloth.category)
          end
          let!(:cloth_variant_from_another_size) do
            create(:cloth_variant, cloth: another_cloth_from_same_category, size: 'S')
          end
          let(:search_parameters) do
            {
              gender: 'male',
              category_id: male_category.id,
              size: 'M'
            }
          end

          it "assigns the category" do
            do_action
            expect(assigns[:category]).to eq male_category
          end

          it "assigns the size" do
            do_action
            expect(assigns[:size]).to eq 'M'
          end

          it "returns only clothes from that category and size" do
            do_action
            expect(assigns[:clothes]).to eq [male_cloth]
          end

          it "returns available sizes without repetition" do
            create(:cloth_variant, size: 'M', cloth: create(:cloth, category: male_category))
            do_action
            expect(assigns[:sizes]).to eq ['M', 'S']
          end
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
