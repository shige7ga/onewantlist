require "rails_helper"

RSpec.describe "RandomWants", type: :system do
  include LoginMacros

  context "ログイン時" do
    let!(:user) { create(:user) }
    let!(:random_want) { create(:random_want, content: "早朝にウォーキングする") }

    before do
      login(user)
      expect(page).to have_current_path(mypage_path)
    end

    context "ガチャを利用できる場合" do
      it "ガチャを回して結果画面を表示できる" do
        visit mypage_path
        click_link "やりたいことガチャ"

        expect(page).to have_current_path(random_want_path)
        expect(page).to have_content("やりたいことガチャ結果")
        expect(page).to have_field("want_content", with: "早朝にウォーキングする")
        expect(page).to have_content("残り9/10回")
      end

      it "再度ガチャを回せる" do
        visit mypage_path
        click_link "やりたいことガチャ"
        expect(page).to have_content("残り9/10回")

        click_link "再度ガチャを回す"
        expect(page).to have_current_path(random_want_path)
        expect(page).to have_field("want_content", with: "早朝にウォーキングする")
        expect(page).to have_content("残り8/10回")
      end
    end

    context "ガチャをまだ回していない場合" do
      it "結果画面へ直接アクセスするとマイページへ戻される" do
        visit random_want_path
        expect(page).to have_current_path(mypage_path)
        expect(page).to have_content("やりたいことガチャを回してください")
      end
    end

    context "ガチャ上限に達している場合" do
      before do
        user.user_status.update!(
          random_gacha_date: Date.current,
          random_gacha_count: UserStatus::RANDOM_GACHA_LIMIT
        )
      end

      it "マイページのガチャボタンがリンクではなくなる" do
        visit mypage_path
        expect(page).to have_content("やりたいことガチャ")
        expect(page).not_to have_link("やりたいことガチャ")
      end
    end
  end

  context "未ログイン時" do
    it "ガチャ結果画面へアクセスするとログイン画面へ移動する" do
      visit random_want_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
