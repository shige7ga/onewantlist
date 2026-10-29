require "rails_helper"

RSpec.describe "簡易メモ", type: :system do
  let!(:user) { create(:user) }
  let!(:user_status) { create(:user_status, owner: user) }

  before do
    login(user)
    expect(page).to have_current_path(mypage_path)
  end

  describe "メモの自動保存" do
    it "入力したメモが自動保存され、再表示できる" do
      visit memo_path

      fill_in "memo_content", with: "新しいアプリを作りたい"

      # 保存状態が「保存済み」になるまで待機
      expect(page).to have_css(
        '[data-memo-autosave-target="status"][data-state="saved"]',
        text: "保存済み",
        wait: 10
      )

      # DBに保存されている
      expect(Memo.find_by!(user: user).content)
        .to eq("新しいアプリを作りたい")

      # 再度アクセスしても内容が保持されている
      visit memo_path

      expect(find("#memo_content").value)
        .to eq("新しいアプリを作りたい")
    end
  end
end
