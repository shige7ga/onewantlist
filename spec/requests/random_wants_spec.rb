require "rails_helper"

RSpec.describe "RandomWants", type: :request do
  let(:user) { create(:user) }
  let(:user_status) { user.user_status }

  let!(:random_want) do
    create(:random_want, content: "行ったことのないカフェに行く")
  end

  describe "GET /random_want" do
    context "未ログイン時" do
      it "ゲストユーザー画面にリダイレクトされる" do
        get random_want_path
        expect(response).to redirect_to(guest_user_path)
      end
    end

    context "ログイン時" do
      before do
        sign_in user
      end

      context "ガチャを回していない場合" do
        it "マイページにリダイレクトされる" do
          get random_want_path
          expect(response).to redirect_to(mypage_path)
        end
      end

      context "ガチャを回している場合" do
        before do
          post draw_random_want_path
        end

        it "正常にレスポンスが返る" do
          get random_want_path
          expect(response).to have_http_status(:ok)
        end
      end

      context "前日のガチャ情報が残っている場合" do
        before do
          # 一度ガチャを回してsessionにrandom_want_idを保存
          post draw_random_want_path

          user_status.update!(
            random_gacha_date: Date.yesterday,
            random_gacha_count: 5
          )
        end

        it "ガチャ回数を0回にリセットする" do
          get random_want_path
          expect(user_status.reload.random_gacha_count).to eq(0)
          expect(user_status.random_gacha_date).to eq(Date.current)
        end

        it "ガチャ結果を破棄してマイページにリダイレクトする" do
          get random_want_path
          expect(response).to redirect_to(mypage_path)
        end
      end
    end
  end

  describe "POST /random_want/draw" do
    context "未ログイン時" do
      it "ガチャ結果画面にリダイレクトされる" do
        post draw_random_want_path
        expect(response).to redirect_to(random_want_path)
      end
    end

    context "ログイン時" do
      before do
        sign_in user
      end

      context "ガチャを利用できる場合" do
        before do
          user_status.update!(
            random_gacha_date: Date.current,
            random_gacha_count: 0
          )
        end

        it "ガチャ回数が1増える" do
          expect {
            post draw_random_want_path
          }.to change {
            user_status.reload.random_gacha_count
          }.from(0).to(1)
        end

        it "ガチャ結果画面にリダイレクトされる" do
          post draw_random_want_path
          expect(response).to redirect_to(random_want_path)
        end

        it "ガチャ結果が保存され、結果画面を表示できる" do
          post draw_random_want_path
          get random_want_path
          expect(response).to have_http_status(:ok)
        end
      end

      context "日付が変わっている場合" do
        before do
          user_status.update!(
            random_gacha_date: Date.yesterday,
            random_gacha_count: 5
          )
        end

        it "回数をリセットして1回目としてガチャを実行する" do
          post draw_random_want_path
          user_status.reload
          expect(user_status.random_gacha_date).to eq(Date.current)
          expect(user_status.random_gacha_count).to eq(1)
        end
      end

      context "ガチャを9回使用している場合" do
        before do
          user_status.update!(
            random_gacha_date: Date.current,
            random_gacha_count: 9
          )
        end

        it "10回目のガチャを実行できる" do
          expect {
            post draw_random_want_path
          }.to change {
            user_status.reload.random_gacha_count
          }.from(9).to(10)

          expect(response).to redirect_to(random_want_path)
        end
      end

      context "ガチャを上限まで使用している場合" do
        before do
          user_status.update!(
            random_gacha_date: Date.current,
            random_gacha_count: UserStatus::RANDOM_GACHA_LIMIT
          )
        end

        it "ガチャ回数が増えない" do
          expect {
            post draw_random_want_path
          }.not_to change {
            user_status.reload.random_gacha_count
          }
        end

        it "マイページにリダイレクトされる" do
          post draw_random_want_path
          expect(response).to redirect_to(mypage_path)
        end
      end
    end
  end
end
