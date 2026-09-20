require 'rails_helper'

RSpec.describe "Wants", type: :request do
  let(:user) { create(:user) }

  describe "GET /wants/new(newアクション)" do
    context "ログイン時" do
      before do
        sign_in user
      end

      it "正常にレスポンスが返る" do
        get new_want_path
        expect(response).to have_http_status(:success)
      end

      context "本日すでにやりたいことを登録している場合" do
        before do
          user.user_status.update!(last_want_registration_date: Date.current)
        end

        it "マイページへリダイレクトされる" do
          get new_want_path
          expect(response).to redirect_to(mypage_path)
        end
      end
    end

    context "未ログイン時" do
      it "ログイン画面へリダイレクトされる" do
        get new_want_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /wants(createアクション)" do
    let(:valid_params) do
      { want: { content: "映画を見る" } }
    end

    context "ログイン時" do
      before do
        sign_in user
      end

      it "やりたいことを登録できる" do
        expect {
          post wants_path, params: valid_params
      }.to change(Want, :count).by(1)
      end

      it "登録後にマイページへリダイレクトされる" do
        post wants_path, params: valid_params
        expect(response).to redirect_to(mypage_path)
      end

      it "やりたいこと登録日が今日に更新される" do
        expect {
          post wants_path, params: valid_params
        }.to change {
          user.user_status.reload.last_want_registration_date
        }.from(nil).to(Date.current)
      end

      context "不正なパラメータの場合" do
        let(:invalid_params) do
          { want: { content: "" } }
        end

        it "Wantが作成されない" do
          expect {
            post wants_path, params: invalid_params
          }.not_to change(Want, :count)
        end

        it "unprocessable_entity 422を返す" do
          post wants_path, params: invalid_params
          expect(response).to have_http_status(422)
        end
      end

      context "本日すでにやりたいことを登録している場合" do
        before do
          user.user_status.update!(last_want_registration_date: Date.current)
        end

        it "マイページへリダイレクトされる" do
          post wants_path, params: valid_params
          expect(response).to redirect_to(mypage_path)
        end

        it "やりたいことは登録されない" do
          expect {
            post wants_path, params: valid_params
          }.not_to change(Want, :count)
        end
      end
    end

    context "未ログイン時" do
      it "ログイン画面へリダイレクトされる" do
        post wants_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /wants/:id(showアクション)" do
    let(:want) { create(:want, owner: user) }

    context "ログイン時" do
      before do
        sign_in user
      end

      it "正常にレスポンスを返す" do
        get want_path(want)
        expect(response).to have_http_status(:success)
      end

      context "他人のWantの場合" do
        let(:other_user) { create(:user, email: "other_test@example.com") }
        let(:other_want) { create(:want, owner: other_user) }

        it "マイページにリダイレクトされる" do
          get want_path(other_want)
          expect(response).to redirect_to(mypage_path)
        end
      end
    end

    context "未ログイン時" do
      it "ログイン画面へリダイレクトされる" do
        get want_path(want)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /wants/:id/edit(editアクション)" do
    let(:want) { create(:want, owner: user) }

    context "ログイン時" do
      before do
        sign_in user
      end

      it "正常にレスポンスを返す" do
        get edit_want_path(want)
        expect(response).to have_http_status(:success)
      end
    end

    context "未ログイン時" do
      it "ログイン画面へリダイレクトされる" do
        get edit_want_path(want)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /wants/:id(updateアクション)" do
    let(:want) { create(:want, owner: user, content: "富士山を登る") }
    let(:valid_params) do
      { want: { content: "映画を見る" } }
    end

    context "ログイン時" do
      before do
        sign_in user
      end

      it "やりたいことを更新できる" do
        expect {
          patch want_path(want), params: valid_params
        }.to change { want.reload.content }
        .from("富士山を登る")
        .to("映画を見る")
      end

      it "更新後に詳細画面へリダイレクトされる" do
        patch want_path(want), params: valid_params
        expect(response).to redirect_to(want_path(want))
      end

      context "不正なパラメータの場合" do
        let(:invalid_params) do
          { want: { content: "" } }
        end

        it "Wantが更新されない" do
          expect {
            post wants_path, params: invalid_params
          }.not_to change { want.reload.content }
        end

        it "unprocessable_entity 422を返す" do
          post wants_path, params: invalid_params
          expect(response).to have_http_status(422)
        end
      end
    end

    context "未ログイン時" do
      it "ログイン画面へリダイレクトされる" do
        patch want_path(want), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE want_path(deleteアクション)" do
    let!(:want) { create(:want, owner: user) }

    context "ログイン時" do
      before do
        sign_in user
      end

      it "やりたいことを削除できる" do
        expect {
          delete want_path(want)
        }.to change(Want, :count).by(-1)
      end

      it "削除した後、マイページにリダイレクトされる" do
        delete want_path(want)
        expect(response).to redirect_to(mypage_path)
      end
    end

    context "未ログイン時" do
      it "ログイン画面へリダイレクトされる" do
        delete want_path(want)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
