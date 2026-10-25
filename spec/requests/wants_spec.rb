require 'rails_helper'

RSpec.describe "Wants", type: :request do
  let(:user) { create(:user) }
  let!(:user_status) { create(:user_status, owner: user) }

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
      it "正常にレスポンスが返る" do
        get new_want_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /wants(createアクション)" do
    let(:valid_params) do
      {
        want: { content: "映画を見る" },
        registration_source: "direct"
      }
    end

    context "ログイン時" do
      before do
        sign_in user
      end

      it "登録成功後にマイページへリダイレクトする" do
        expect {
          post wants_path, params: valid_params
        }.to change(Want, :count).by(1)

        expect(response).to redirect_to(mypage_path)
      end

      context "不正なパラメータの場合" do
        let(:invalid_params) do
          {
            want: { content: "" },
            registration_source: "direct"
          }
        end

        it "登録せず、エラーメッセージを表示する" do
          expect {
            post wants_path, params: invalid_params
          }.not_to change(Want, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:alert]).to include("登録できませんでした")

          document = response.parsed_body

          expect(document.at_css("#want_content_errors").text)
            .to include("やりたいこと")

          expect(document.at_css("#want_content")["aria-invalid"])
            .to eq("true")
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
      end
    end

    context "未ログイン時" do
      it "ゲストユーザー画面へリダイレクトされる" do
        post wants_path, params: valid_params
        expect(response).to redirect_to(guest_user_path)
      end
    end

    context "登録元が不正な場合" do
      before { sign_in user }

      it "登録せず、マイページにリダイレクトする" do
        expect {
          post wants_path, params: {
            want: { content: "映画を見る" },
            registration_source: "invalid"
          }
        }.not_to change(Want, :count)

        expect(response).to redirect_to(mypage_path)
        expect(flash[:alert]).to include("登録情報が不正です")
      end
    end

    context "ガチャのセッションが存在しない場合" do
      before { sign_in user }

      it "登録せず、マイページにリダイレクトする" do
        expect {
          post wants_path, params: {
            want: { content: "映画を見る" },
            registration_source: "gacha"
          }
        }.not_to change(Want, :count)

        expect(response).to redirect_to(mypage_path)
        expect(flash[:alert]).to include("登録情報が不正です")
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
      it "ゲストユーザー画面へリダイレクトされる" do
        get want_path(want)
        expect(response).to redirect_to(guest_user_path)
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
      it "ゲストユーザー画面へリダイレクトされる" do
        get edit_want_path(want)
        expect(response).to redirect_to(guest_user_path)
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

      it "やりたいことを更新し、詳細画面へリダイレクトする" do
        expect {
          patch want_path(want), params: valid_params
        }.to change { want.reload.content }
        .from("富士山を登る")
        .to("映画を見る")

        expect(response).to redirect_to(want_path(want))
      end

      context "不正なパラメータの場合" do
        let(:invalid_params) do
          { want: { content: "" } }
        end

        it "更新せず、422を返す" do
          expect {
            patch want_path(want), params: invalid_params
          }.not_to change { want.reload.content }

          expect(response).to have_http_status(422)
        end

        it "更新せず、入力欄の下にエラーを表示する" do
          expect {
            patch want_path(want), params: invalid_params
          }.not_to change { want.reload.content }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:alert]).to include("更新できませんでした")

          document = response.parsed_body

          expect(document.at_css("#want_content_errors").text)
            .to include("やりたいこと")

          expect(document.at_css("#want_content")["aria-describedby"])
            .to eq("want_content_errors")
        end
      end

      context "不正なステータスの場合" do
        it "更新せず、ステータスのエラーを表示する" do
          patch want_path(want), params: {
            want: { status: "invalid_status" }
          }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(want.reload.status).to eq("not_started")

          document = response.parsed_body

          expect(document.at_css("#want_status_errors").text)
            .to include("選択肢から選んでください")
        end
      end

      context "過去の期限日の場合" do
        it "更新せず、期限日のエラーを表示する" do
          patch want_path(want), params: {
            want: { due_date: Date.yesterday.to_s }
          }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(want.reload.due_date).to be_nil

          document = response.parsed_body

          expect(document.at_css("#want_due_date_errors").text)
            .to include("本日以降の日付を指定してください")
        end
      end
    end

    context "未ログイン時" do
      it "ゲストユーザー画面へリダイレクトされる" do
        patch want_path(want), params: valid_params
        expect(response).to redirect_to(guest_user_path)
      end
    end
  end

  describe "DELETE want_path(deleteアクション)" do
    let!(:want) { create(:want, owner: user) }

    context "ログイン時" do
      before do
        sign_in user
      end

      it "やりたいことを削除し、マイページへリダイレクトする" do
        expect {
          delete want_path(want)
        }.to change(Want, :count).by(-1)

        expect(response).to redirect_to(mypage_path)
      end
    end

    context "未ログイン時" do
      it "ゲストユーザー画面へリダイレクトされる" do
        delete want_path(want)
        expect(response).to redirect_to(guest_user_path)
      end
    end
  end

  describe "他人のWantに対する操作" do
    let(:other_user) do
      create(:user, email: "other@example.com")
    end

    let!(:other_want) do
      create(:want, owner: other_user, content: "旅行する")
    end

    before { sign_in user }

    it "他人のWantを更新できない" do
      patch want_path(other_want),
            params: { want: { content: "書き換え" } }

      expect(other_want.reload.content).to eq("旅行する")
      expect(response).to redirect_to(mypage_path)
    end

    it "他人のWantを削除できない" do
      expect {
        delete want_path(other_want)
      }.not_to change(Want, :count)

      expect(response).to redirect_to(mypage_path)
    end
  end
end
