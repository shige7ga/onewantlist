require "rails_helper"

RSpec.describe Users::CreateInitialAdmin do
  let(:email) { "admin@example.com" }
  let(:password) { "initial-password" }

  subject(:service) do
    described_class.new(
      email: email,
      password: password
    )
  end

  describe "#call" do
    it "管理者とUserStatusを作成する" do
      expect {
        service.call
      }.to change(User, :count).by(1)
        .and change(UserStatus, :count).by(1)

      admin = User.find_by!(email: email)

      expect(admin).to be_admin
      expect(admin.user_status).to be_present
      expect(admin.valid_password?(password)).to be true
    end

    it "再実行しても管理者が重複しない" do
      admin = service.call

      expect {
        service.call
      }.not_to change(User, :count)

      expect(service.call.id).to eq(admin.id)
    end

    it "再実行しても変更後のパスワードを上書きしない" do
      admin = service.call

      admin.update!(
        password: "changed-password",
        password_confirmation: "changed-password"
      )

      expect {
        service.call
      }.not_to change { admin.reload.encrypted_password }

      expect(
        admin.reload.valid_password?("changed-password")
      ).to be true
    end

    it "既存の一般ユーザーを管理者に変更しない" do
      user = create(:user, email: email)

      expect {
        service.call
      }.to raise_error(
        RuntimeError,
        "指定したメールアドレスは既に使用されています"
      )

      expect(user.reload).to be_general
    end
  end
end
