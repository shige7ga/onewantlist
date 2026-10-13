require "rails_helper"

RSpec.describe "ヘッダー", type: :system do
  context "未ログイン時" do
    it "無料登録とログイン導線が表示される" do
      visit root_path

      expect(page).to have_link("無料登録")

      find("header summary").click

      expect(page).to have_link("ログイン")
      expect(page).to have_no_link("ログアウト")
    end
  end

  context "ログイン時" do
    let!(:user) { create(:user) }
    let!(:user_status) { create(:user_status, owner: user) }

    it "ユーザー設定とログアウトが表示される" do
      login(user)

      within("header") do
        expect(page).to have_no_link("無料登録")
      end

      find("header summary").click

      expect(page).to have_link("マイページ")
      expect(page).to have_link("マイステータス")
      expect(page).to have_link("ユーザー設定")
      expect(page).to have_link("ログアウト")
    end
  end
end
