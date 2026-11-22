require "rails_helper"

RSpec.describe Admin::DashboardPolicy do
  describe "#show?" do
    it "管理者はアクセスが許可される" do
      user = build(:user, :admin)
      policy = described_class.new(user, :dashboard)

      expect(policy.show?).to be true
    end

    it "一般ユーザーはアクセスが拒否される" do
      user = build(:user)
      policy = described_class.new(user, :dashboard)

      expect(policy.show?).to be false
    end

    it "検証用ユーザーはアクセスが拒否される" do
      user = build(:user, :tester)
      policy = described_class.new(user, :dashboard)

      expect(policy.show?).to be false
    end

    it "未ログインユーザーはアクセスが拒否される" do
      policy = described_class.new(nil, :dashboard)

      expect(policy.show?).to be false
    end
  end
end
