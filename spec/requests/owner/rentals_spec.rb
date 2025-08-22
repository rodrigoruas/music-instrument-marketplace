require 'rails_helper'

RSpec.describe "Owner::Rentals", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/owner/rentals/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/owner/rentals/show"
      expect(response).to have_http_status(:success)
    end
  end

end
