require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Menus' do
  header 'Authorization', :authorization
  let(:authorization) { "Bearer #{token}" }
  let(:token) { AuthToken.encode(user_id: user.id) }
  let(:user) { create(:user) }
  let!(:atlanta) { create(:city, name: 'Atlanta') }

  get '/:city' do
    let(:today_product) { create(:product) }
    let(:tomorrow_product) { create(:product) }
    let(:city) { 'atlanta' }
    let(:today_menu) { Menu.create(date: Time.zone.parse('2016-01-01'), products: [today_product]) }
    let(:tomorrow_menu) { Menu.create(date: Time.zone.parse('2016-01-02'), products: [tomorrow_product]) }

    before do
      Timecop.freeze today_menu.date
    end

    context "default date" do
      example "getting today's menu", document: :public do
        do_request
        expect(json).to eq(
          "date" => "2016-01-01",
          "products" => [{
            "id" => today_product.id,
            "name" => today_product.name,
            "description" => today_product.description,
            "price_cents" => today_product.price_cents,
            "price_currency" => today_product.price_currency,
            "image" => today_product.image.url(:thumb)
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
          "products" => [{
            "id" => tomorrow_product.id,
            "name" => tomorrow_product.name,
            "description" => tomorrow_product.description,
            "price_cents" => tomorrow_product.price_cents,
            "price_currency" => tomorrow_product.price_currency,
            "image" => tomorrow_product.image.url(:thumb)
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
