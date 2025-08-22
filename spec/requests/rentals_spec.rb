require 'rails_helper'

RSpec.describe "Rentals", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/rentals/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/rentals/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/rentals/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/rentals/create"
      expect(response).to have_http_status(:success)
    end
  end

end
