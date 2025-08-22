require 'rails_helper'

RSpec.describe "Owner::Dashboards", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/owner/dashboard/index"
      expect(response).to have_http_status(:success)
    end
  end

end
