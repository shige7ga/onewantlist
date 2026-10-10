require "rails_helper"

RSpec.describe "Statuses", type: :request do
  describe "GET /status" do
    context "ゲストユーザーの場合" do
      it "ステータス詳細ページを表示できる" do
        get status_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("マイステータス")
        expect(response.body).to include("ログインの記録")
        expect(response.body).to include("アクションの記録")
      end
    end

    context "ログインユーザーの場合" do
      let(:user) { create(:user) }
      let!(:user_status) { create(:user_status, owner: user) }

      before do
        sign_in user
      end

      it "ステータス詳細ページを表示できる" do
        get status_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("マイステータス")
      end
    end
  end
end
