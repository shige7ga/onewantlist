require 'rails_helper'

RSpec.describe "Top", type: :system do
  context "未ログイン時" do
    it "トップページが表示される" do
      visit root_path

      expect(page).to have_content("わんわんとリスト")
      expect(page).to have_link("無料登録")
      expect(page).to have_link("ログイン")
    end

    it "ログイン画面へ移動できる" do
      visit root_path
      click_link "ログイン", match: :first

      expect(page).to have_current_path(new_user_session_path)
    end

    it "ユーザー登録画面へ移動できる" do
      visit root_path
      click_link "無料登録", match: :first

      expect(page).to have_current_path(new_user_registration_path)
    end
  end
end
