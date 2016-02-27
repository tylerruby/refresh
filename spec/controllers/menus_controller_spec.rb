require 'rails_helper'

RSpec.describe MenusController, type: :controller do
  describe 'GET #show', :wip do
    context 'when current address is present' do
      let(:atlanta) { create(:city, name: 'Atlanta') }
      let(:current_address) { create :address, city: atlanta, address: '4th Av.' }
      let(:region) { create(:region, address: current_address) }
      let!(:menu) { create(:menu, date: '2016-01-04', region: region) }

      before do
        stub_address('4th Av., Atlanta, GA', 40.7143528, -74.0059731)

        allow_any_instance_of(ApplicationController)
          .to receive(:current_address).and_return(current_address)
      end

      def do_action
        get :show, city: 'atlanta'
      end

      context 'when today is a normal weekday' do
        before do
          Timecop.travel Time.zone.parse('04-01-2016 01:00')
          do_action
        end

        it 'show menu of current day' do
          expect(assigns[:menu]).to eq menu
        end
      end


      context 'when today is weekend' do
        before do
          Timecop.travel Time.zone.parse('02-01-2016 01:00')
          do_action
        end

        it 'show menu of first available day' do
          expect(assigns[:menu]).to eq menu
        end
      end

      context 'when today is holiday' do
        before do
          Timecop.travel Time.zone.parse('01-01-2016 01:00')
          do_action
        end

        it 'show menu of first available day' do
          expect(assigns[:menu]).to eq menu
        end
      end
    end
  end
end

