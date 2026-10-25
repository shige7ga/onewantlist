require 'rails_helper'

RSpec.describe "Users", type: :system do
  let!(:user) { create(:user) }
  let!(:user_status) { create(:user_status, owner: user) }
  let!(:want) { create(:want, owner: user, content: "富士山に登る") }
  let!(:random_want) { create(:random_want, content: "早朝にウォーキングする") }

  context "ログイン時" do
    before do
      login(user)
      expect(page).to have_current_path(mypage_path)
    end

    it "マイページが表示される" do
      visit mypage_path
      expect(page).to have_content("富士山に登る")
      expect(page).to have_link("やりたいことガチャ")
      expect(page).to have_link("やりたいこと登録")
    end

    it "やりたいこと登録画面へ移動できる" do
      visit mypage_path
      click_link "やりたいこと登録"
      expect(page).to have_current_path(new_want_path)
    end

    it "やりたいことガチャ画面へ移動できる" do
      visit mypage_path
      click_link "やりたいことガチャ"
      expect(page).to have_current_path(random_want_path)
      expect(page).to have_content("早朝にウォーキングする")
    end

    it "他ユーザーのやりたいことは表示されない" do
      other_user = create(:user, email: "other@example.com")
      create(:want, owner: other_user, content: "海外旅行へ行く")

      visit mypage_path
      expect(page).to have_content("富士山に登る")
      expect(page).not_to have_content("海外旅行へ行く")
    end

    it "プロフィール更新失敗時にエラーを表示する" do
      visit edit_user_registration_path

      fill_in "user_email", with: "changed@example.com"
      fill_in "user_current_password", with: "wrong_password"

      click_button "更新する"

      expect(page).to have_css(
        "#user_current_password_errors",
        text: "現在のパスワード"
      )

      expect(page).to have_css(
        'input#user_current_password[aria-invalid="true"]'
      )

      expect(user.reload.email).not_to eq("changed@example.com")
    end
  end

  context "未ログイン時" do
    it "ログイン画面にリダイレクトされる" do
      visit mypage_path
      expect(page).to have_current_path(new_user_session_path)
    end

    it "ユーザー登録失敗時に入力欄の下へエラーを表示する" do
      visit new_user_registration_path

      fill_in "user_name", with: "テストユーザー"
      fill_in "user_email", with: "invalid-email"
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password"

      click_button "登録する"

      expect(page).to have_css(
        "#user_email_errors",
        text: "メールアドレス"
      )

      expect(page).to have_css(
        'input#user_email[aria-invalid="true"]'
      )
    end
  end
end
