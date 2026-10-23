require "rails_helper"

RSpec.describe Users::TransferGuestData do
  let(:guest_user) { GuestUser.create! }
  let!(:user_status) do
    guest_user.create_user_status!(
      level: 4,
      experience: 35
    )
  end
  let!(:want) do
    create(:want, owner: guest_user)
  end
  let(:user) { create(:user, email: "new@example.com") }

  subject(:transfer) do
    described_class.new(
      guest_user: guest_user,
      user: user
    ).call
  end

  describe "#call" do
    it "UserStatusを引き継ぎ、レベルとEXPを維持する" do
      expect {
        transfer
      }.not_to change(UserStatus, :count)

      expect(user_status.reload.owner).to eq(user)
      expect(user_status.level).to eq(4)
      expect(user_status.experience).to eq(35)
    end

    it "Wantを新規ユーザーへ移行する" do
      transfer

      expect(want.reload.owner).to eq(user)
    end

    it "移行後にゲストだけを削除する" do
      transfer

      expect(GuestUser.exists?(guest_user.id)).to be false
      expect(UserStatus.exists?(user_status.id)).to be true
      expect(Want.exists?(want.id)).to be true
    end

    it "移行中にエラーが発生した場合はロールバックする" do
      allow(guest_user).to receive(:destroy!)
        .and_raise(StandardError, "削除失敗")

      expect {
        transfer
      }.to raise_error(StandardError, "削除失敗")

      expect(user_status.reload.owner).to eq(guest_user)
      expect(want.reload.owner).to eq(guest_user)
      expect(GuestUser.exists?(guest_user.id)).to be true
    end
  end
end
