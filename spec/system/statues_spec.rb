require "rails_helper"

RSpec.describe "マイステータス画面", type: :system do
  let!(:user) { create(:user) }
  let!(:user_status) { create(:user_status, owner: user) }

  before do
    login(user)
    visit status_path(start_date: "2026-11-01")
  end

  describe "画面表示" do
    it "ステータス情報とカレンダーが表示される" do
      expect(page).to have_content("マイステータス")
      expect(page).to have_content("レベル・経験値")
      expect(page).to have_content("ログインの記録")
      expect(page).to have_content("アクションの記録")
      expect(page).to have_content("登録カレンダー")
    end
  end

  describe "カレンダーの月切り替え" do
    it "翌月に切り替えられる" do
      expect(page).to have_css(
        'turbo-frame#registration_calendar time[datetime="2026-11"]'
      )

      within "turbo-frame#registration_calendar" do
        click_link "次の月 ＞"
      end

      expect(page).to have_css(
        'turbo-frame#registration_calendar time[datetime="2026-12"]'
      )
    end

    it "前月に切り替えられる" do
      within "turbo-frame#registration_calendar" do
        click_link "＜ 前の月"
      end

      expect(page).to have_css(
        'turbo-frame#registration_calendar time[datetime="2026-10"]'
      )
    end

    it "ページ全体を再読み込みせずに月を切り替えられる" do
      # ページ全体にテスト用の目印を付ける
      page.execute_script(
        "document.body.dataset.calendarTest = 'preserved'"
      )

      within "turbo-frame#registration_calendar" do
        click_link "次の月 ＞"
      end

      # カレンダーが更新されたことを確認
      expect(page).to have_css(
        'turbo-frame#registration_calendar time[datetime="2026-12"]'
      )

      # bodyが差し替わっていないことを確認
      expect(
        page.evaluate_script("document.body.dataset.calendarTest")
      ).to eq("preserved")
    end
  end

  describe "登録履歴の表示" do
    it "登録した日付に肉球スタンプが表示される" do
      create(
        :want,
        owner: user,
        created_at: Time.zone.local(2026, 11, 5, 12)
      )

      visit status_path(start_date: "2026-11-01")

      within '[data-date="2026-11-05"]' do
        expect(page).to have_css('img[src*="paws"]')
      end

      within '[data-date="2026-11-06"]' do
        expect(page).to have_no_css('img[src*="paws"]')
      end
    end

    it "表示月の登録件数が正しく表示される" do
      create(
        :want,
        owner: user,
        created_at: Time.zone.local(2026, 11, 5, 12)
      )

      create(
        :want,
        owner: user,
        created_at: Time.zone.local(2026, 11, 8, 12)
      )

      visit status_path(start_date: "2026-11-01")

      within "turbo-frame#registration_calendar" do
        expect(page).to have_content("表示月の登録：")
        expect(page).to have_content("2 件")
      end
    end
  end
end
