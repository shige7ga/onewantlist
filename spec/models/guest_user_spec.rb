require "rails_helper"

RSpec.describe GuestUser, type: :model do
  describe "#experience_finished?" do
    let(:guest) { GuestUser.create! }
    let!(:status) { guest.create_user_status! }

    before do
      guest.update!(
        direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT,
        gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT
      )
    end

    it "自由登録の体験枠が残っていれば終了と判定しない" do
      guest.update!(direct_registration_count: GuestUser::DIRECT_REGISTRATION_LIMIT - 1)
      status.update!(random_gacha_date: Date.yesterday)

      expect(guest.experience_finished?).to be false
    end

    it "ガチャの体験枠が残っていれば終了と判定しない" do
      guest.update!(gacha_usage_count: GuestUser::GACHA_USAGE_LIMIT - 1)
      status.update!(random_gacha_date: Date.yesterday)

      expect(guest.experience_finished?).to be false
    end

    context "自由登録・ガチャの両方を上限まで使用した場合" do
      it "ガチャ最終日の未登録状態では、登録機会を残すため終了と判定しない" do
        status.update!(
          random_gacha_date: Date.current,
          last_want_registration_date: nil
        )

        expect(guest.experience_finished?).to be false
      end

      it "ガチャ最終日にやりたいことを登録済みなら終了と判定する" do
        status.update!(
          random_gacha_date: Date.current,
          last_want_registration_date: Date.current
        )

        expect(guest.experience_finished?).to be true
      end

      it "ガチャ最終日の翌日になれば、未登録でも終了と判定する" do
        status.update!(
          random_gacha_date: Date.yesterday,
          last_want_registration_date: nil
        )

        expect(guest.experience_finished?).to be true
      end
    end
  end
end
