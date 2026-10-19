require "rails_helper"

RSpec.describe "ゲスト体験終了モーダル", type: :system do
  let(:guest) { GuestUser.last }
  let(:status) { guest.user_status }

  before do
    visit guest_user_path
  end

  it "自由登録の上限到達時に専用のモーダルを開閉できる" do
    guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT)
    visit guest_user_path

    find('button[data-guest-limit-type="direct"]').click

    within("dialog[open]") do
      expect(page).to have_content("やりたいこと登録、3回達成！")
      expect(page).to have_link("無料登録して続ける", href: new_user_registration_path)
      click_button "今は登録しない"
    end

    expect(page).to have_no_css("dialog[open]")
  end

  it "ガチャの上限到達時はガチャ専用のタイトルを表示する" do
    guest.update!(gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT)
    status.update!(random_gacha_date: Date.yesterday)
    visit guest_user_path

    find('button[data-guest-limit-type="gacha"]').click

    within("dialog[open]") do
      expect(page).to have_content("ガチャ体験、3回達成！")
    end
  end

  it "ガチャ3回目の当日は未登録ならガチャへの導線が残る" do
    guest.update!(gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT)
    status.update!(random_gacha_date: Date.current, last_want_registration_date: nil)
    visit guest_user_path

    expect(page).to have_link("やりたいことガチャ")
    expect(page).to have_no_css('button[data-guest-limit-type="gacha"]')
  end

  it "ガチャ3回目の当日でも登録済みなら利用制限のモーダルを開ける" do
    guest.update!(gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT)
    status.update!(random_gacha_date: Date.current, last_want_registration_date: Date.current)
    visit guest_user_path

    find('button[data-guest-limit-type="gacha"]').click

    within("dialog[open]") do
      expect(page).to have_content("ガチャ体験、3回達成！")
    end
  end

  it "両方の体験が終了した翌日には、自動で終了モーダルが表示される" do
    guest.update!(
      direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT,
      gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT
    )
    status.update!(random_gacha_date: Date.yesterday)
    visit guest_user_path

    within("dialog[open]") do
      expect(page).to have_content("ゲスト体験、上限まで達成！")
    end
  end

  it "未ログインのヘッダーからゲストページへ移動できる" do
    visit root_path
    find("header summary").click

    expect(page).to have_link("ゲストページ", href: guest_user_path)
  end

  it "EXP演出がある場合は演出完了後に終了モーダルを表示する" do
    guest.update!(
      direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT - 1,
      gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT
    )
    # Lv3の開始EXPに合わせ、登録による10EXPでレベルアップさせない
    status.update!(random_gacha_date: Date.yesterday, level: 3, experience: 20)
    visit guest_user_path

    click_link "やりたいこと登録"
    fill_in "want_content", with: "気になっていた本を読む"
    click_button "登録"

    expect(page).to have_current_path(guest_user_path)
    expect(page).to have_css('[data-guest-limit-modal-wait-for-exp-value="true"]', visible: :all)
    expect(page).to have_no_css("dialog[open]", wait: 0)
    expect(page).to have_css("dialog[open]", wait: 10)
    expect(page).to have_content("ゲスト体験、上限まで達成！")
  end
  it "レベルアップ演出があっても、終了後にゲスト体験モーダルを表示する" do
    guest.update!(
      direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT - 1,
      gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT
    )
    status.update!(random_gacha_date: Date.yesterday)
    visit guest_user_path

    click_link "やりたいこと登録"
    fill_in "want_content", with: "近くの博物館を見学する"
    click_button "登録"

    expect(page).to have_current_path(guest_user_path)
    expect(page).to have_css('[data-guest-limit-modal-wait-for-exp-value="true"]', visible: :all)
    expect(page).to have_css('[data-controller="level-up-modal"][aria-hidden="false"]', wait: 6)
    expect(page).to have_css("dialog[open]", wait: 15)
    expect(page).to have_content("ゲスト体験、上限まで達成！")
  end
end
