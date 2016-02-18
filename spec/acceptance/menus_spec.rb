require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Menus' do
  header 'Authorization', :authorization
  let(:authorization) { "Bearer #{token}" }
  let(:token) { AuthToken.encode(user_id: user.id) }

  let(:address) { create(:address, address: "My special address") }
  let(:user) { create(:user, current_address: address.dup) }
  let(:user_region) { create(:region, address: address.dup) }

  before do
    stub_address("My special address, Atlanta, GA", 0, 0)
  end

  get '/:city.json' do
    let!(:atlanta) { create(:city, name: 'Atlanta') }
    let(:city) { 'atlanta' }

    let(:menu_from_another_region) { create(:menu, date: today_date) }
    let(:product_from_another_region) { create(:product) }
    let!(:menu_product_from_another_region) { create(:menu_product, menu: menu_from_another_region, product: product_from_another_region) }

    let(:today_date) { "2016-01-01" }
    let(:today_menu) { create(:menu, date: today_date, region: user_region) }
    let(:today_product) { create(:product) }
    let!(:today_menu_product) { create(:menu_product, menu: today_menu, product: today_product) }

    let(:tomorrow_date) { "2016-01-02" }
    let(:tomorrow_menu) { create(:menu, date: tomorrow_date, region: user_region) }
    let(:tomorrow_product) { create(:product) }
    let!(:tomorrow_menu_product) { create(:menu_product, menu: tomorrow_menu, product: tomorrow_product) }

    before do
      Timecop.freeze today_menu.date
    end

    context "default date" do
      example "getting today's menu", document: :public do
        do_request
        expect(json).to eq(
          "date" => today_date,
          "menu_products" => [{
            "id" => today_menu_product.id,

            "menu" => {
              "id" => today_menu.id,
              "date" => today_date
            },

            "product" => {
              "id" => today_product.id,
              "name" => today_product.name,
              "description" => today_product.description,
              "price_cents" => today_product.price_cents,
              "price_currency" => today_product.price_currency,
              "image" => today_product.image.url(:thumb)
            }
          }]
        )
      end
    end

    context "passing a date" do
      parameter :date, "The menu's date"
      let(:date) { tomorrow_menu.date }

      example "getting tomorrow's menu", document: :public do
        do_request
        expect(json).to eq(
          "date" => "2016-01-02",
          "menu_products" => [{
            "id" => tomorrow_menu_product.id,

            "menu" => {
              "id" => tomorrow_menu.id,
              "date" => tomorrow_date
            },

            "product" => {
              "id" => tomorrow_product.id,
              "name" => tomorrow_product.name,
              "description" => tomorrow_product.description,
              "price_cents" => tomorrow_product.price_cents,
              "price_currency" => tomorrow_product.price_currency,
              "image" => tomorrow_product.image.url(:thumb)
            }
          }]
        )
      end
    end

    context "passing a date not yet available" do
      parameter :date, "The menu's date"
      let(:date) { tomorrow_menu.date + 1.day }

      example "trying to get an unavailable menu", document: :public do
        do_request
        expect(response_status).to eq 422
        expect(json).to eq(
          "message" => "Menu not found for this date and region."
        )
      end
    end

    context "user's region isn't available" do
      parameter :date, "The menu's date"

      let(:other_address) { create(:address, address: "Some other address") }
      let(:user) { create(:user, current_address: other_address) }
      let(:date) { today_date }

      before do
        stub_address("Some other address, Atlanta, GA", 999, 999)
      end

      example "trying to get an unavailable menu", document: :public do
        do_request
        expect(response_status).to eq 422
        expect(json).to eq(
          "message" => "Menu not found for this date and region."
        )
      end
    end

    context "user doesn't have a current address" do
      parameter :date, "The menu's date"

      let(:user) { create(:user, current_address: nil) }
      let(:date) { today_date }

      before do
        stub_address("Some other address, Atlanta, GA", 999, 999)
      end

      example "trying to get an unavailable menu", document: :public do
        do_request
        expect(response_status).to eq 422
        expect(json).to eq(
          "message" => "You should choose a current address first."
        )
      end
    end
  end
end
