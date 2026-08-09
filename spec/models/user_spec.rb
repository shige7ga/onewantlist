require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "正しい情報ならユーザーを作成できる" do
      user = build(:user)
      expect(user).to be_valid
    end
  end
end
