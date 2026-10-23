require "rails_helper"

RSpec.describe Gacha::Draw do
  let(:owner) { create(:user) }
  let!(:user_status) { create(:user_status, owner: owner) }
  let!(:random_want) { create(:random_want) }

  subject(:result) do
    described_class.new(owner: owner).call
  end

  describe "#call" do
    it "ガチャを抽選して1日の利用回数を増やす" do
      expect(result.success?).to be true
      expect(result.random_want).to eq(random_want)
      expect(user_status.reload.random_gacha_count).to eq(1)
    end

    it "日付が変わったら利用回数を初期化する" do
      user_status.update!(
        random_gacha_date: Date.yesterday,
        random_gacha_count: 5
      )

      result

      expect(user_status.reload).to have_attributes(
        random_gacha_date: Date.current,
        random_gacha_count: 1
      )
    end

    it "10回目の抽選で日次アクションのEXPを付与する" do
      user_status.update!(
        random_gacha_date: Date.current,
        random_gacha_count: 9,
        last_action_date: Date.yesterday
      )

      expect(result.events).to include(
        hash_including(
          type: "exp_up",
          source: "daily_action"
        )
      )

      expect(user_status.reload.random_gacha_count).to eq(10)
    end

    it "10回利用済みの場合は抽選しない" do
      user_status.update!(
        random_gacha_date: Date.current,
        random_gacha_count: 10
      )

      expect(result.error).to eq(:daily_limit)
      expect(result.random_want).to be_nil
      expect(result.events).to eq([])
      expect(user_status.reload.random_gacha_count).to eq(10)
    end

    it "本日登録済みの場合は抽選しない" do
      user_status.update!(
        last_want_registration_date: Date.current
      )

      expect(result.error).to eq(:already_registered)
    end

    it "EXP更新に失敗したらガチャ回数も元に戻す" do
      user_status.update!(
        random_gacha_date: Date.current,
        random_gacha_count: 9,
        last_action_date: Date.yesterday
      )

      allow(Experience::Grant).to receive(:new)
        .and_raise(StandardError, "EXP付与失敗")

      expect { result }.to raise_error(StandardError, "EXP付与失敗")

      expect(user_status.reload.random_gacha_count).to eq(9)
    end
  end
end
