require 'rails_helper'

RSpec.describe "Top", type: :request do
  let(:user) { create(:user) }
  let!(:user_status) { create(:user_status, owner: user) }

  describe "GET /" do
    context "ログイン時" do
      before do
        sign_in user
      end
      it "マイページにリダイレクトされる" do
        get root_path
        expect(response).to redirect_to(mypage_path)
      end
    end

    context "未ログイン時" do
      it "正常にレスポンスが返る" do
        get root_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
