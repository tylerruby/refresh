require 'rails_helper'

RSpec.describe ClothesController, type: :controller do

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
