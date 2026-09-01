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

    context "action_countについて" do
      it "action_countが0の場合、有効" do
        user_status = build(:user_status, action_count: 0)
        expect(user_status).to be_valid
      end

      it "action_countが存在しない場合、無効" do
        user_status = build(:user_status, action_count: nil)
        expect(user_status).to be_invalid
      end

      it "action_countがマイナスの場合、無効" do
        user_status = build(:user_status, action_count: -1)
        expect(user_status).to be_invalid
      end
    end

    context "action_streakについて" do
      it "action_streakが0の場合、有効" do
        user_status = build(:user_status, action_streak: 0)
        expect(user_status).to be_valid
      end

      it "action_streakが存在しない場合、無効" do
        user_status = build(:user_status, action_streak: nil)
        expect(user_status).to be_invalid
      end

      it "action_streakがマイナスの場合、無効" do
        user_status = build(:user_status, action_streak: -1)
        expect(user_status).to be_invalid
      end
    end

    context "longest_action_streakについて" do
      it "longest_action_streakが0の場合、有効" do
        user_status = build(:user_status, longest_action_streak: 0)
        expect(user_status).to be_valid
      end

      it "longest_action_streakが存在しない場合、無効" do
        user_status = build(:user_status, longest_action_streak: nil)
        expect(user_status).to be_invalid
      end

      it "longest_action_streakがマイナスの場合、無効" do
        user_status = build(:user_status, longest_action_streak: -1)
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

    context "last_action_dateについて" do
      it "last_action_dateが本日の日付なら有効" do
        user_status = build(:user_status, last_action_date: Date.current)
        expect(user_status).to be_valid
      end

      it "last_action_dateが過去の日付なら有効" do
        user_status = build(:user_status, last_action_date: Date.current - 1.day)
        expect(user_status).to be_valid
      end

      it "last_action_dateが未来の日付なら無効" do
        user_status = build(:user_status, last_action_date: Date.current + 1.day)
        expect(user_status).to be_invalid
      end

      it "last_action_dateがnilなら有効" do
        user_status = build(:user_status, last_action_date: nil)
        expect(user_status).to be_valid
      end
    end

    context "random_gacha_countについて" do
      it "random_gacha_countが0の場合、有効" do
        user_status = build(:user_status, random_gacha_count: 0)
        expect(user_status).to be_valid
      end

      it "random_gacha_countが存在しない場合、無効" do
        user_status = build(:user_status, random_gacha_count: nil)
        expect(user_status).to be_invalid
      end

      it "random_gacha_countがマイナスの場合、無効" do
        user_status = build(:user_status, random_gacha_count: -1)
        expect(user_status).to be_invalid
      end
    end

    context "random_gacha_dateについて" do
      it "random_gacha_dateが本日の日付なら有効" do
        user_status = build(:user_status, random_gacha_date: Date.current)
        expect(user_status).to be_valid
      end

      it "random_gacha_dateが過去の日付なら有効" do
        user_status = build(:user_status, random_gacha_date: Date.current - 1.day)
        expect(user_status).to be_valid
      end

      it "random_gacha_dateが未来の日付なら無効" do
        user_status = build(:user_status, random_gacha_date: Date.current + 1.day)
        expect(user_status).to be_invalid
      end

      it "random_gacha_dateがnilなら有効" do
        user_status = build(:user_status, random_gacha_date: nil)
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
