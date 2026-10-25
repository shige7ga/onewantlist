require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /users/sign_in" do
    it "正しい認証情報ならログインできる" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password"
        }
      }

      expect(response).to be_redirect
      expect(flash[:notice]).to eq("ログインしました")
    end

    it "パスワードが間違っている場合は共通のエラーを表示する" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "wrong_password"
        }
      }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert])
        .to eq("メールアドレスまたはパスワードが正しくありません")
    end

    it "存在しないメールアドレスでも同じエラーを表示する" do
      post user_session_path, params: {
        user: {
          email: "unknown@example.com",
          password: "password"
        }
      }

      expect(flash[:alert])
        .to eq("メールアドレスまたはパスワードが正しくありません")
    end
  end
end
