require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    context "正常系" do
      it "正しい情報ならユーザーを作成できる" do
        user = build(:user)
        expect(user).to be_valid
      end
    end

    context "nameについて" do
      it "nilでも有効" do
        user = build(:user, name: nil)
        expect(user).to be_valid
      end

      it "空文字の場合、nilとして扱う" do
        user = build(:user, name: "")
        expect(user.name).to be_nil
      end

      it "スペースのみの場合、nilとして扱う" do
        user = build(:user, name: "    ")
        expect(user.name).to be_nil
      end

      it "TABのみの場合、nilとして扱う" do
        user = build(:user, name: "\t\t")
        expect(user.name).to be_nil
      end

      it "nameの前後に空白の場合に、前後空白が除去される" do
        user = build(:user, name: "  test_user  ")
        expect(user.name).to eq("test_user")
      end

      it "40文字なら有効" do
        user = build(:user, name: "a" * 40)
        expect(user).to be_valid
      end

      it "41文字なら無効" do
        user = build(:user, name: "a" * 41)
        expect(user).to be_invalid
      end
    end

    context "emailについて" do
      it "nilなら無効" do
        user = build(:user, email: nil)
        expect(user).to be_invalid
      end

      it "正しいemail形式なら有効" do
        user = build(:user, email: "example@test.com")
        expect(user).to be_valid
      end

      it "正しくないemail形式なら無効" do
        user = build(:user, email: "exampletest.com")
        expect(user).to be_invalid
      end

      it "重複しているemailなら無効" do
        create(:user, email: "example@test.com")
        user = build(:user, email: "example@test.com")
        expect(user).to be_invalid
      end
    end

    context "passwordについて" do
      it "nilなら無効" do
        user = build(:user, password: nil)
        expect(user).to be_invalid
      end

      it "5文字なら無効" do
        user = build(:user, password: "a" * 5)
        expect(user).to be_invalid
      end

      it "6文字なら有効" do
        user = build(:user, password: "a" * 6)
        expect(user).to be_valid
      end

      it "32文字なら有効" do
        user = build(:user, password: "a" * 32)
        expect(user).to be_valid
      end

      it "33文字なら無効" do
        user = build(:user, password: "a" * 33)
        expect(user).to be_invalid
      end
    end

    context "password_confirmationについて" do
      it "passwordと一致しない場合は無効" do
        user = build(
          :user,
          password: "password",
          password_confirmation: "different"
        )
        expect(user).to be_invalid
      end
    end
  end
end
