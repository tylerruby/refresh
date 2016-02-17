require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Menus' do
  header 'Authorization', :authorization
  let(:authorization) { "Bearer #{token}" }
  let(:token) { AuthToken.encode(user_id: user.id) }
  let(:user) { create(:user) }
  let!(:atlanta) { create(:city, name: 'Atlanta') }

  get '/:city.json' do
    let(:city) { 'atlanta' }

    let(:today_date) { "2016-01-01" }
    let(:today_menu) { Menu.create(date: today_date) }
    let(:today_product) { create(:product) }
    let!(:today_menu_product) { create(:menu_product, menu: today_menu, product: today_product) }

    let(:tomorrow_date) { "2016-01-02" }
    let(:tomorrow_menu) { Menu.create(date: tomorrow_date) }
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
        expect { do_request }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
