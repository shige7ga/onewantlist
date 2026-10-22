require "rails_helper"

RSpec.describe "ゲスト体験制限", type: :request do
  let(:guest) { GuestUser.last }
  let(:status) { guest.user_status }
  let(:direct_params) do
    { want: { content: "近所の公園を散歩する" }, registration_source: "direct" }
  end

  before do
    # 初回アクセスでゲスト用CookieとUserStatusを生成する
    get guest_user_path
  end

  describe "GET /wants/new" do
    it "自由登録が残り1回なら登録画面を表示できる" do
      guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT - 1)

      get new_want_path

      expect(response).to have_http_status(:ok)
    end

    it "自由登録の上限到達後は画面への直接アクセスも制限する" do
      guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT)

      get new_want_path

      expect(response).to redirect_to(new_user_registration_path)
      expect(flash[:alert]).to include("ゲスト利用制限に達しました")
    end
  end

  describe "POST /wants" do
    it "自由登録の3回目は成功し、利用回数が上限に達する" do
      guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT - 1)

      expect {
        post wants_path, params: direct_params
      }.to change(Want, :count).by(1)

      expect(guest.reload.direct_registration_count).to eq(GuestUser::DIRECT_REGISTRATION_LIMIT)
      expect(status.reload.last_want_registration_date).to eq(Date.current)
    end

    it "自由登録の上限後はPOSTを直接送っても登録できない" do
      guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT)

      expect {
        post wants_path, params: direct_params
      }.not_to change(Want, :count)

      expect(response).to redirect_to(new_user_registration_path)
    end

    it "登録に失敗した場合は自由登録の回数が増えない" do
      guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT - 1)

      post wants_path, params: { want: { content: "" }, registration_source: "direct" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(guest.reload.direct_registration_count).to eq(GuestUser::DIRECT_REGISTRATION_LIMIT - 1)
    end

    it "ガチャ経由の登録は自由登録3回の上限を超えていても可能で、回数に加算しない" do
      create(:random_want, content: "新しいカフェに行く")
      guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT)
      post draw_random_want_path
      expect(response).to redirect_to(random_want_path)

      expect {
        post wants_path, params: {
          want: { content: "新しいカフェに行く" },
          registration_source: "gacha"
        }
      }.to change(Want, :count).by(1)

      expect(response).to redirect_to(guest_user_path)
      expect(guest.reload.direct_registration_count).to eq(GuestUser::DIRECT_REGISTRATION_LIMIT)
    end
  end

  describe "POST /random_want/draw" do
    before do
      create(:random_want, content: "未経験の料理を作る")
    end

    it "ガチャ3回目の利用日なら、上限到達後も当日中の抽選を続けられる" do
      guest.update!(gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT)
      status.update!(random_gacha_date: Date.current, random_gacha_count: 1)

      expect {
        post draw_random_want_path
      }.to change { status.reload.random_gacha_count }.from(1).to(2)

      expect(response).to redirect_to(random_want_path)
      expect(guest.reload.gacha_usage_count).to eq(GuestUser::GACHA_USAGE_LIMIT)
    end

    it "ガチャ3回分を使い切った翌日は抽選を制限する" do
      guest.update!(gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT)
      status.update!(random_gacha_date: Date.yesterday, random_gacha_count: 2)

      post draw_random_want_path

      expect(response).to redirect_to(new_user_registration_path)
      expect(status.reload.random_gacha_count).to eq(2)
    end
  end

  describe "GET /guest/user" do
    it "どちらかの体験枠が残る場合は自動表示しない" do
      guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT)
      status.update!(random_gacha_date: Date.yesterday)

      get guest_user_path

      expect(response.body).to include('data-guest-limit-modal-auto-value="false"')
      expect(response.parsed_body.at_css('button[data-guest-limit-type="direct"]')).to be_present
    end

    it "ガチャ最終日の未登録状態では終了モーダルを自動表示しない" do
      guest.update!(
        direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT,
        gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT
      )
      status.update!(random_gacha_date: Date.current, last_want_registration_date: nil)

      get guest_user_path

      expect(response.body).to include('data-guest-limit-modal-auto-value="false"')
      expect(response.parsed_body.at_css('button[data-guest-limit-type="gacha"]')).to be_nil
    end

    it "両方の体験が終了するとモーダル自動表示フラグを渡す" do
      guest.update!(
        direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT,
        gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT
      )
      status.update!(random_gacha_date: Date.yesterday)

      get guest_user_path

      expect(response.body).to include('data-guest-limit-modal-auto-value="true"')
    end

    it "本日の登録状況を表示する" do
      status.update!(last_want_registration_date: Date.current)

      get guest_user_path

      expect(response.body).to include("本日登録済")
      expect(response.body).not_to include("今日は未登録")
    end

    it "未登録時は未登録のバッジを表示する" do
      get guest_user_path

      expect(response.body).to include("今日は未登録")
      expect(response.body).not_to include("本日登録済")
    end

    it "自由登録の上限未到達なら登録リンクを表示する" do
      guest.update!(
        direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT - 1
      )

      get guest_user_path

      expect(response.parsed_body.at_css(
        "a[href='#{new_want_path}']"
      )).to be_present

      expect(response.parsed_body.at_css(
        'button[data-guest-limit-type="direct"]'
      )).to be_nil
    end
  end
end
