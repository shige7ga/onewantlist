require "rails_helper"

RSpec.describe "Admin::Dashboards", type: :request do
  describe "GET /admin" do

    context "管理者の場合" do
      let(:admin) { create(:user, :admin) }

      before do
        create(:user_status, owner: admin)
        sign_in admin
      end

      it "管理画面を表示できる" do
        get admin_root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(
          "管理者ダッシュボード"
        )
      end
    end

    context "一般ユーザーの場合" do
      let(:user) { create(:user) }

      before do
        create(:user_status, owner: user)
        sign_in user
      end

      it "マイページへリダイレクトされる" do
        get admin_root_path

        expect(response).to redirect_to(mypage_path)
      end
    end

    context "検証用ユーザーの場合" do
      let(:tester) { create(:user, :tester) }

      before do
        create(:user_status, owner: tester)
        sign_in tester
      end

      it "マイページへリダイレクトされる" do
        get admin_root_path

        expect(response).to redirect_to(mypage_path)
      end
    end

    context "未ログインの場合" do
      it "ログイン画面へリダイレクトされる" do
        get admin_root_path

        expect(response).to redirect_to(
          new_user_session_path
        )
      end
    end
  end
end
