require "rails_helper"

RSpec.describe "自由登録・ガチャの相互遷移", type: :system do
  let!(:random_want) do
    create(:random_want, content: "早朝にウォーキングする")
  end

  context "ログイン時" do
    let!(:user) { create(:user) }
    let!(:user_status) { create(:user_status, owner: user) }

    before do
      login(user)
      expect(page).to have_current_path(mypage_path)
    end

    it "ガチャ結果画面から自由登録画面へ遷移できる" do
      click_link "やりたいことガチャ"
      expect(page).to have_current_path(random_want_path)

      click_link "やりたいこと登録画面へ →"

      expect(page).to have_current_path(new_want_path)
      expect(page).to have_field("want_content")
    end

    it "自由登録画面からガチャ結果画面へ遷移できる" do
      visit new_want_path

      click_link "やりたいことガチャ画面へ →"

      expect(page).to have_current_path(random_want_path)
      expect(page).to have_content("やりたいことガチャ結果")
      expect(page).to have_content("早朝にウォーキングする")

      # ガチャ抽選が1回実行されたことを確認
      expect(user_status.reload.random_gacha_count).to eq(1)
    end
  end

  context "ゲスト利用時" do
    let(:guest) { GuestUser.last }
    let(:status) { guest.user_status }

    before do
      visit guest_user_path
    end

    it "自由登録の制限到達時はガチャ結果画面でモーダルを表示する" do
      # ガチャを回して結果画面へ
      click_link "やりたいことガチャ"
      expect(page).to have_current_path(random_want_path)

      # 自由登録の上限に到達させる
      guest.update!(
        direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT
      )

      visit random_want_path

      # リンクではなくモーダル表示用ボタンになっている
      find('button[data-guest-limit-type="direct"]').click

      # ガチャ結果画面から遷移していないことを確認
      expect(page).to have_current_path(random_want_path)

      within("dialog[open]") do
        expect(page).to have_content("やりたいこと登録、3回達成！")
        expect(page).to have_link(
          "無料登録して続ける",
          href: new_user_registration_path
        )

        click_button "今は登録しない"
      end

      expect(page).to have_no_css("dialog[open]")
      expect(page).to have_current_path(random_want_path)
    end

    it "ガチャの制限到達時は自由登録画面でモーダルを表示する" do
      # ガチャの体験上限に到達させる
      guest.update!(
        gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT
      )
      status.update!(random_gacha_date: Date.yesterday)

      visit new_want_path

      expect(page).to have_current_path(new_want_path)

      # モーダル表示用ボタンをクリック
      find('button[data-guest-limit-type="gacha"]').click

      # 自由登録画面から遷移していないことを確認
      expect(page).to have_current_path(new_want_path)

      within("dialog[open]") do
        expect(page).to have_content("ガチャ体験、3回達成！")
        click_button "今は登録しない"
      end

      expect(page).to have_no_css("dialog[open]")
      expect(page).to have_current_path(new_want_path)
      expect(page).to have_field("want_content")
    end


    it "ガチャ3回目の当日は未登録なら自由登録画面からガチャを回せる" do
      guest.update!(
        gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT
      )

      status.update!(
        random_gacha_date: Date.current,
        random_gacha_count: 1,
        last_want_registration_date: nil
      )

      visit new_want_path

      # 制限ボタンではなく通常のリンクが表示される
      expect(page).to have_link("やりたいことガチャ画面へ →")
      expect(page).to have_no_css(
        'button[data-guest-limit-type="gacha"]'
      )

      click_link "やりたいことガチャ画面へ →"

      expect(page).to have_current_path(random_want_path)
      expect(page).to have_content("やりたいことガチャ結果")

      # ガチャ体験の利用日数は増加しない
      expect(guest.reload.gacha_usage_count).to eq(
        GuestUser::GACHA_USAGE_LIMIT
      )

      # 本日の抽選回数だけが加算される
      expect(status.reload.random_gacha_count).to eq(2)
    end
  end
end
