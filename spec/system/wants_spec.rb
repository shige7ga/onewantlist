require "rails_helper"

RSpec.describe "Wants", type: :system do
  include LoginMacros

  context "ログイン時" do
    let!(:user) { create(:user) }

    before do
      login(user)
      expect(page).to have_current_path(mypage_path)
    end

    context "やりたいこと登録" do
      it "やりたいことを登録できる" do
        visit new_want_path

        fill_in "want_content", with: "富士山に登る"
        click_button "登録"

        expect(page).to have_current_path(mypage_path)
        expect(page).to have_content("富士山に登る")
        expect(page).to have_content("やりたいことを登録しました")
      end

      it "入力内容が不正な場合は登録できない" do
        visit new_want_path

        fill_in "want_content", with: ""
        click_button "登録"

        expect(page).to have_current_path(new_want_path)
        expect(page).to have_content("登録できませんでした")
      end

      it "本日すでに登録済みの場合は登録画面へアクセスできない" do
        user.user_status.update!(
          last_want_registration_date: Date.current
        )
        visit new_want_path

        expect(page).to have_current_path(mypage_path)
        expect(page).to have_content("今日は既にやりたいことを登録完了しています")
      end
    end

    context "やりたいこと詳細・編集・削除" do
      let!(:want) { create(:want, owner: user, content: "富士山に登る") }

      it "自分のやりたいこと詳細を表示できる" do
        visit want_path(want)
        expect(page).to have_content("富士山に登る")
      end

      it "やりたいことを編集できる" do
        visit edit_want_path(want)
        fill_in "want_content", with: "高尾山に登る"
        click_button "更新"

        expect(page).to have_current_path(want_path(want))
        expect(page).to have_content("高尾山に登る")
        expect(page).to have_content("更新しました")
      end

      it "やりたいことを削除できる" do
        visit want_path(want)
        click_button "削除"
        click_button "削除する"

        expect(page).to have_current_path(mypage_path)
        expect(page).not_to have_content("富士山に登る")
      end
    end

    context "アクセス制御" do
      let!(:other_user) { create(:user, email: "other@example.com") }
      let!(:other_want) { create(:want, owner: other_user, content: "海外旅行へ行く") }

      it "他ユーザーのやりたいこと詳細にはアクセスできない" do
        visit want_path(other_want)
        expect(page).to have_current_path(mypage_path)
        expect(page).to have_content("アクセス権がありません")
      end

      it "他ユーザーのやりたいこと編集画面にはアクセスできない" do
        visit edit_want_path(other_want)
        expect(page).to have_current_path(mypage_path)
        expect(page).to have_content("アクセス権がありません")
      end
    end
  end

  context "未ログイン" do
    it "登録画面へアクセスするとログイン画面へ移動する" do
      visit new_want_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
