require "rails_helper"

RSpec.describe Memo, type: :model do
  let(:user) { create(:user) }

  describe "バリデーション" do
    context "contentについて" do
      it "nilでも有効" do
        memo = build(:memo, user: user, content: nil)

        expect(memo).to be_valid
      end

      it "空文字でも有効" do
        memo = build(:memo, user: user, content: "")

        expect(memo).to be_valid
      end

      it "2000文字なら有効" do
        memo = build(:memo, user: user, content: "a" * 2000)

        expect(memo).to be_valid
      end

      it "2001文字なら無効" do
        memo = build(:memo, user: user, content: "a" * 2001)

        expect(memo).to be_invalid
        expect(memo.errors[:content]).to be_present
      end
    end

    context "userについて" do
      it "ユーザーが紐づいていれば有効" do
        memo = build(:memo, user: user)

        expect(memo).to be_valid
      end

      it "ユーザーが存在しなければ無効" do
        memo = build(:memo, user: nil)

        expect(memo).to be_invalid
      end
    end
  end

  describe "関連付け" do
    it "ユーザーとメモが関連付いている" do
      memo = create(:memo, user: user)

      expect(memo.user).to eq(user)
      expect(user.memo).to eq(memo)
    end

    it "user_idにユニークインデックスがある" do
      expect(
        ActiveRecord::Base.connection.index_exists?(
          :memos, :user_id, unique: true
        )
      ).to be true
    end

    it "ユーザーを削除するとメモも削除される" do
      create(:memo, user: user)

      expect {
        user.destroy!
      }.to change(Memo, :count).by(-1)
    end
  end
end
