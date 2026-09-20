require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /mypage" do
    let(:user) { create(:user) }

    context "ログイン時" do
      before do
        sign_in user
      end

      let!(:my_want) { create(:want, owner: user, content: "映画を見る") }
      let!(:other_user) { create(:user, email: "other@test") }
      let!(:other_want) { create(:want, owner: other_user, content: "富士山に登る") }

      it "正常にレスポンスが返る" do
        get mypage_path
        expect(response).to have_http_status(200)
      end

      it "自分のやりたいことだけ表示される" do
        get mypage_path
        expect(response.body).to include("映画を見る")
        expect(response.body).not_to include("富士山に登る")
      end
    end

    context "未ログイン時" do
      it "ログイン画面にリダイレクトされる" do
        get mypage_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
