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
        expect(user_status.level).to eq(3)
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

      it "登録失敗時にゲストデータが保持される" do
        get guest_user_path

        guest_user = GuestUser.last
        user_status = guest_user.user_status
        want = create(:want, owner: guest_user)

        post user_registration_path, params: invalid_params

        expect(GuestUser.exists?(guest_user.id)).to be true
        expect(user_status.reload.owner).to eq(guest_user)
        expect(want.reload.owner).to eq(guest_user)
      end

      it "登録失敗時にFlashと項目別エラーを表示する" do
        post user_registration_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq("ユーザー登録できませんでした")

        document = response.parsed_body

        expect(document.at_css("#user_email_errors").text)
          .to include("メールアドレス")

        expect(document.at_css("#user_email")["aria-invalid"])
          .to eq("true")

        expect(document.at_css("#user_email")["aria-describedby"])
          .to eq("user_email_errors")
      end
    end

    context "ゲストデータがある場合" do
      let(:valid_params) do
        {
          user: {
            name: "test",
            email: "transfer@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      before do
        get guest_user_path

        @guest_user = GuestUser.last
        @user_status_id = @guest_user.user_status.id
        @want = create(:want, owner: @guest_user)
      end

      it "登録後もゲストのデータを引き継ぐ" do
        post user_registration_path, params: valid_params

        user = User.last

        expect(user.user_status.id).to eq(@user_status_id)
        expect(user.wants).to contain_exactly(@want)
        expect(GuestUser.exists?(@guest_user.id)).to be false
        expect(response).to redirect_to(mypage_path)
      end
    end
  end

  describe "PUT /users" do
    let(:user) { create(:user) }
    let!(:user_status) { create(:user_status, owner: user) }

    before do
      sign_in user
    end

    context "正常なパラメータの場合" do
      it "ユーザー情報を更新できる" do
        put user_registration_path, params: {
          user: {
            email: "changed@example.com",
            current_password: "password"
          }
        }

        expect(user.reload.email).to eq("changed@example.com")
        expect(response).to be_redirect
        expect(flash[:notice]).to eq("ユーザー情報を編集しました")
      end
    end

    context "現在のパスワードが間違っている場合" do
      it "更新せず、エラーを表示する" do
        put user_registration_path, params: {
          user: {
            email: "changed@example.com",
            current_password: "wrong_password"
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.email).not_to eq("changed@example.com")
        expect(flash[:alert]).to eq("ユーザー情報を更新できませんでした")

        document = response.parsed_body

        expect(document.at_css("#user_current_password_errors").text)
          .to include("現在のパスワード")
      end
    end

    context "メールアドレスが不正な場合" do
      it "メールアドレスのエラーを表示する" do
        put user_registration_path, params: {
          user: {
            email: "invalid-email",
            current_password: "password"
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)

        document = response.parsed_body

        expect(document.at_css("#user_email_errors").text)
          .to include("メールアドレス")
      end
    end

    context "パスワード確認が一致しない場合" do
      it "パスワード確認のエラーを表示する" do
        put user_registration_path, params: {
          user: {
            password: "newpassword",
            password_confirmation: "different",
            current_password: "password"
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)

        document = response.parsed_body

        expect(document.at_css("#user_password_confirmation_errors").text)
          .to include("パスワード確認")

        expect(user.reload.valid_password?("password")).to be true
      end
    end
  end
end
