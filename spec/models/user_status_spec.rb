require "rails_helper"

RSpec.describe UserStatus, type: :model do
  describe "バリデーション" do
    context "初期値が設定されている場合" do
      it "有効である" do
        user_status = build(:user_status)
        expect(user_status).to be_valid
      end
    end

    context "levelについて" do
      it "levelが1の場合、有効" do
        user_status = build(:user_status, level: 1)
        expect(user_status).to be_valid
      end

      it "levelが存在しない場合、無効" do
        user_status = build(:user_status, level: nil)
        expect(user_status).to be_invalid
      end

      it "levelがマイナスの場合、無効" do
        user_status = build(:user_status, level: -1)
        expect(user_status).to be_invalid
      end

      it "levelが0の場合、無効" do
        user_status = build(:user_status, level: 0)
        expect(user_status).to be_invalid
      end
    end

    context "experimenceについて" do
      it "experimenceが0の場合、有効" do
        user_status = build(:user_status, experimence: 0)
        expect(user_status).to be_valid
      end

      it "experimenceが存在しない場合、無効" do
        user_status = build(:user_status, experimence: nil)
        expect(user_status).to be_invalid
      end

      it "experimenceがマイナスの場合、無効" do
        user_status = build(:user_status, experimence: -1)
        expect(user_status).to be_invalid
      end
    end

    context "login_countについて" do
      it "login_countが1の場合、有効" do
        user_status = build(:user_status, login_count: 1)
        expect(user_status).to be_valid
      end

      it "login_countが存在しない場合、無効" do
        user_status = build(:user_status, login_count: nil)
        expect(user_status).to be_invalid
      end

      it "login_countがマイナスの場合、無効" do
        user_status = build(:user_status, login_count: -1)
        expect(user_status).to be_invalid
      end

      it "login_countが0の場合、無効" do
        user_status = build(:user_status, login_count: 0)
        expect(user_status).to be_invalid
      end
    end

    context "login_streakについて" do
      it "login_streakが1の場合、有効" do
        user_status = build(:user_status, login_streak: 1)
        expect(user_status).to be_valid
      end

      it "login_streakが存在しない場合、無効" do
        user_status = build(:user_status, login_streak: nil)
        expect(user_status).to be_invalid
      end

      it "login_streakがマイナスの場合、無効" do
        user_status = build(:user_status, login_streak: -1)
        expect(user_status).to be_invalid
      end

      it "login_streakが0の場合、無効" do
        user_status = build(:user_status, login_streak: 0)
        expect(user_status).to be_invalid
      end
    end

    context "longest_login_streakについて" do
      it "longest_login_streakが1の場合、有効" do
        user_status = build(:user_status, longest_login_streak: 1)
        expect(user_status).to be_valid
      end

      it "longest_login_streakが存在しない場合、無効" do
        user_status = build(:user_status, longest_login_streak: nil)
        expect(user_status).to be_invalid
      end

      it "longest_login_streakがマイナスの場合、無効" do
        user_status = build(:user_status, longest_login_streak: -1)
        expect(user_status).to be_invalid
      end

      it "longest_login_streakが0の場合、無効" do
        user_status = build(:user_status, longest_login_streak: 0)
        expect(user_status).to be_invalid
      end
    end

    context "want_registration_countについて" do
      it "want_registration_countが0の場合、有効" do
        user_status = build(:user_status, want_registration_count: 0)
        expect(user_status).to be_valid
      end

      it "want_registration_countが存在しない場合、無効" do
        user_status = build(:user_status, want_registration_count: nil)
        expect(user_status).to be_invalid
      end

      it "want_registration_countがマイナスの場合、無効" do
        user_status = build(:user_status, want_registration_count: -1)
        expect(user_status).to be_invalid
      end
    end

    context "want_registration_streakについて" do
      it "want_registration_streakが0の場合、有効" do
        user_status = build(:user_status, want_registration_streak: 0)
        expect(user_status).to be_valid
      end

      it "want_registration_streakが存在しない場合、無効" do
        user_status = build(:user_status, want_registration_streak: nil)
        expect(user_status).to be_invalid
      end

      it "want_registration_streakがマイナスの場合、無効" do
        user_status = build(:user_status, want_registration_streak: -1)
        expect(user_status).to be_invalid
      end
    end

    context "longest_want_registration_streakについて" do
      it "longest_want_registration_streakが0の場合、有効" do
        user_status = build(:user_status, longest_want_registration_streak: 0)
        expect(user_status).to be_valid
      end

      it "longest_want_registration_streakが存在しない場合、無効" do
        user_status = build(:user_status, longest_want_registration_streak: nil)
        expect(user_status).to be_invalid
      end

      it "longest_want_registration_streakがマイナスの場合、無効" do
        user_status = build(:user_status, longest_want_registration_streak: -1)
        expect(user_status).to be_invalid
      end
    end

    context "last_login_dateについて" do
      it "last_login_dateが本日の日付なら有効" do
        user_status = build(:user_status, last_login_date: Date.current)
        expect(user_status).to be_valid
      end

      it "last_login_dateが過去の日付なら有効" do
        user_status = build(:user_status, last_login_date: Date.current - 1.day)
        expect(user_status).to be_valid
      end

      it "last_login_dateが未来の日付なら無効" do
        user_status = build(:user_status, last_login_date: Date.current + 1.day)
        expect(user_status).to be_invalid
      end

      it "last_login_dateがnilなら無効" do
        user_status = build(:user_status, last_login_date: nil)
        expect(user_status).to be_invalid
      end
    end

    context "last_registration_dateについて" do
      it "last_registration_dateが本日の日付なら有効" do
        user_status = build(:user_status, last_registration_date: Date.current)

        expect(user_status).to be_valid
      end

      it "last_registration_dateが過去の日付なら有効" do
        user_status = build(
          :user_status,
          last_registration_date: Date.current - 1.day
        )

        expect(user_status).to be_valid
      end

      it "last_registration_dateが未来の日付なら無効" do
        user_status = build(
          :user_status,
          last_registration_date: Date.current + 1.day
        )

        expect(user_status).to be_invalid
      end

      it "last_registration_dateがnilなら有効" do
        user_status = build(:user_status, last_registration_date: nil)

        expect(user_status).to be_valid
      end
    end
  end

  describe "Userとの関連" do
    it "User作成時にUserStatusが紐づく" do
      user = create(:user)
      expect(user.user_status).to be_present
    end
  end
end
