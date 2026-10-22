require "rails_helper"

RSpec.describe Wants::Register do
  let(:owner) { create(:user) }
  let!(:user_status) { create(:user_status, owner: owner) }
  let(:attributes) { { content: "映画を見る" } }
  let(:source) { :direct }

  subject(:result) do
    described_class.new(
      owner: owner,
      attributes: attributes,
      source: source
    ).call
  end

  describe "#call" do
    context "通常の登録" do
      it "Wantを保存し、登録日とEXPを更新する" do
        expect {
          result
        }.to change(Want, :count).by(1)

        expect(result.success?).to be true
        expect(result.want.owner).to eq(owner)

        expect(user_status.reload.last_want_registration_date)
          .to eq(Date.current)

        expect(result.events).to include(
          hash_including(
            type: "exp_up",
            source: "daily_action"
          )
        )
      end
    end

    context "本日すでに登録済みの場合" do
      before do
        user_status.update!(
          last_want_registration_date: Date.current
        )
      end

      it "二重登録を防止する" do
        expect {
          result
        }.not_to change(Want, :count)

        expect(result.error).to eq(:already_registered)
        expect(result.events).to eq([])
      end
    end

    context "登録内容が不正な場合" do
      let(:attributes) { { content: "" } }

      it "Wantを保存せず、エラーを返す" do
        expect {
          result
        }.not_to change(Want, :count)

        expect(result.error).to eq(:invalid_want)
        expect(result.want.errors[:content]).to be_present
        expect(user_status.reload.last_want_registration_date).to be_nil
      end
    end

    context "ゲストの自由登録の場合" do
      let(:owner) { GuestUser.create! }

      it "3回目の登録は成功し、回数が上限に達する" do
        owner.update!(
          direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT - 1
        )

        expect {
          result
        }.to change(Want, :count).by(1)

        expect(result.success?).to be true
        expect(owner.reload.direct_registration_count)
          .to eq(GuestUser::DIRECT_REGISTRATION_LIMIT)
      end

      it "上限到達後は登録を拒否する" do
        owner.update!(
          direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT
        )

        expect {
          result
        }.not_to change(Want, :count)

        expect(result.error).to eq(:guest_limit)
        expect(owner.reload.direct_registration_count)
          .to eq(GuestUser::DIRECT_REGISTRATION_LIMIT)
      end

      it "保存失敗時には登録回数を増やさない" do
        owner.update!(direct_registration_count: 1)

        attributes[:content] = ""

        expect {
          result
        }.not_to change(Want, :count)

        expect(result.error).to eq(:invalid_want)
        expect(owner.reload.direct_registration_count).to eq(1)
      end

      it "後続処理で例外が発生したら登録処理全体を取り消す" do
        allow(Experience::Grant).to receive(:new)
          .and_raise(StandardError, "EXP付与失敗")

        expect {
          result
        }.to raise_error(StandardError, "EXP付与失敗")

        expect(Want.where(owner: owner).count).to eq(0)
        expect(owner.reload.direct_registration_count).to eq(0)
        expect(user_status.reload.last_want_registration_date).to be_nil
      end
    end

    context "ゲストのガチャ経由登録の場合" do
      let(:owner) { GuestUser.create! }
      let(:source) { :gacha }

      it "自由登録の上限に達していても登録でき、自由登録回数は増やさない" do
        owner.update!(
          direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT
        )

        expect {
          result
        }.to change(Want, :count).by(1)

        expect(result.success?).to be true
        expect(owner.reload.direct_registration_count)
          .to eq(GuestUser::DIRECT_REGISTRATION_LIMIT)
      end
    end
  end
end
