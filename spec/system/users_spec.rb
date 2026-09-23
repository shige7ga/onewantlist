require 'rails_helper'

RSpec.describe "Users", type: :system do
  include LoginMacros

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
      expect(page).to have_content("ユーザー名")
      expect(page).to have_content("富士山に登る")
      expect(page).to have_link("やりたいことガチャ")
      expect(page).to have_link("やりたいこと登録")
      expect(page).to have_link("プロフィール編集")
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

    it "プロフィール編集画面へ移動できる" do
      visit mypage_path
      click_link "プロフィール編集"
      expect(page).to have_current_path(edit_user_registration_path)
    end

    it "他ユーザーのやりたいことは表示されない" do
      other_user = create(:user, email: "other@example.com")
      create(:want, owner: other_user, content: "海外旅行へ行く")

      visit mypage_path
      expect(page).to have_content("富士山に登る")
      expect(page).not_to have_content("海外旅行へ行く")
    end
  end

  context "未ログイン時" do
    it "ログイン画面にリダイレクトされる" do
      visit mypage_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
