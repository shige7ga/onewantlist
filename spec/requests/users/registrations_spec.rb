require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "POST /users" do
    context "有効なパラメータの場合" do
      let(:valid_params) do
        {
          user: {
            name: "test",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      it "ユーザーが作成される" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "nameが保存される" do
        post user_registration_path, params: valid_params
        expect(User.last.name).to eq("test")
      end

      it "マイページにリダイレクトされる" do
        post user_registration_path, params: valid_params
        expect(response).to redirect_to(mypage_path)
      end

      it "ユーザー登録時のステータス更新が行われる" do
        post user_registration_path, params: valid_params
        user_status = User.last.user_status
        expect(user_status.level).to eq(2)
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        {
          user: {
            name: "test",
            email: "",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      it "ユーザーが作成されない" do
        expect {
          post user_registration_path, params: invalid_params
        }.not_to change(User, :count)
      end

      it "マイページにリダイレクトされない" do
        post user_registration_path, params: invalid_params
        expect(response).not_to redirect_to(mypage_path)
      end
    end
  end
end
