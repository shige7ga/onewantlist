require 'rails_helper'

RSpec.describe "Top", type: :system do
  include LoginMacros

  context "未ログイン時" do
    it "トップページが表示される" do
      visit root_path

      expect(page).to have_content("わんわんとリスト")
      expect(page).to have_content("1日1つだけ「やりたいこと」を登録して")
      expect(page).to have_link("ユーザー登録")
      expect(page).to have_link("ログイン")
    end

    it "ログイン画面へ移動できる" do
      visit root_path
      within(".hero") do
        click_link "ログイン"
      end

      expect(page).to have_current_path(new_user_session_path)
    end

    it "ユーザー登録画面へ移動できる" do
      visit root_path
      within(".hero") do
        click_link "ユーザー登録"
      end

      expect(page).to have_current_path(new_user_registration_path)
    end
  end

  context "ログイン時" do
    let!(:user) { create(:user) }
    let!(:user_status) { create(:user_status, owner: user) }

     before do
      login(user)
      expect(page).to have_current_path(mypage_path)
    end

    it "トップページではなくマイページが表示される" do
      visit root_path
      expect(page).to have_current_path(mypage_path)
    end
  end
end
