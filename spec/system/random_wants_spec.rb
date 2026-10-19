require "rails_helper"

RSpec.describe "RandomWants", type: :system do
  context "ログイン時" do
    let!(:user) { create(:user) }
    let!(:user_status) { create(:user_status, owner: user) }
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
        expect(page).to have_content("早朝にウォーキングする")
        expect(page).to have_no_field("want_content")
        expect(page).to have_content("残り9/10回")
      end

      it "再度ガチャを回せる" do
        visit mypage_path
        click_link "やりたいことガチャ"
        expect(page).to have_content("残り9/10回")

        click_button "再度ガチャを回す"
        expect(page).to have_current_path(random_want_path)
        expect(page).to have_content("早朝にウォーキングする")
        expect(page).to have_no_field("want_content")
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

    it "ガチャ結果からそのまま登録できる" do
      visit mypage_path
      click_link "やりたいことガチャ"

      expect {
        click_button "この内容で登録する"
      }.to change(Want, :count).by(1)

      expect(page).to have_current_path(mypage_path)
      expect(Want.last.content).to eq("早朝にウォーキングする")
    end

    it "ガチャ結果を編集して登録できる" do
      visit mypage_path
      click_link "やりたいことガチャ"

      click_link "内容を編集する"

      expect(page).to have_current_path(edit_random_want_path)

      fill_in "want_content", with: "早朝に公園を散歩する"

      expect {
        click_button "登録する"
      }.to change(Want, :count).by(1)

      expect(Want.last.content).to eq("早朝に公園を散歩する")
      expect(page).to have_current_path(mypage_path)
    end

    it "編集画面から結果画面に戻れる" do
      visit mypage_path
      click_link "やりたいことガチャ"

      count_before = user_status.reload.random_gacha_count

      click_link "内容を編集する"
      click_link "戻る"

      expect(page).to have_current_path(random_want_path)
      expect(page).to have_content("早朝にウォーキングする")

      expect(user_status.reload.random_gacha_count).to eq(count_before)
    end
  end

  context "未ログイン時" do
    it "ガチャ結果画面へアクセスするとゲストユーザー画面へ移動する" do
      visit random_want_path
      expect(page).to have_current_path(guest_user_path)
    end
  end
end
