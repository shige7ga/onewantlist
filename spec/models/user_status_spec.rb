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

    context "experienceについて" do
      it "experienceが0の場合、有効" do
        user_status = build(:user_status, experience: 0)
        expect(user_status).to be_valid
      end

      it "experienceが存在しない場合、無効" do
        user_status = build(:user_status, experience: nil)
        expect(user_status).to be_invalid
      end

      it "experienceがマイナスの場合、無効" do
        user_status = build(:user_status, experience: -1)
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

    context "last_want_registration_dateについて" do
      it "last_want_registration_dateが本日の日付なら有効" do
        user_status = build(:user_status, last_want_registration_date: Date.current)
        expect(user_status).to be_valid
      end

      it "last_want_registration_dateが過去の日付なら有効" do
        user_status = build(:user_status, last_want_registration_date: Date.current - 1.day)
        expect(user_status).to be_valid
      end

      it "last_want_registration_dateが未来の日付なら無効" do
        user_status = build(:user_status, last_want_registration_date: Date.current + 1.day)
        expect(user_status).to be_invalid
      end

      it "last_want_registration_dateがnilなら有効" do
        user_status = build(:user_status, last_want_registration_date: nil)
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

  describe "#random_gacha_available?" do
    it "random_gacha_dateが本日でない時、trueを返す" do
      user_status = build(:user_status, random_gacha_date: Date.yesterday, random_gacha_count: UserStatus::RANDOM_GACHA_LIMIT)
      expect(user_status.random_gacha_available?).to eq(true)
    end

    it "random_gacha_dateが本日かつrandom_gacha_countが上限未満の場合、trueを返す" do
      user_status = build(:user_status, random_gacha_date: Date.current, random_gacha_count: UserStatus::RANDOM_GACHA_LIMIT - 1)
      expect(user_status.random_gacha_available?).to eq(true)
    end

    it "random_gacha_dateが本日かつrandom_gacha_countが上限の場合、falseを返す" do
      user_status = build(:user_status, random_gacha_date: Date.current, random_gacha_count: UserStatus::RANDOM_GACHA_LIMIT)
      expect(user_status.random_gacha_available?).to eq(false)
    end
  end

  describe "#record_daily_login!" do
    let(:user) { create(:user) }
    let(:user_status) { user.user_status }

    context "最終ログイン日が昨日の場合" do
      before do
        user_status.update!(last_login_date: Date.yesterday)
      end

      it "last_login_dateを今日に更新する" do
        expect {
          user_status.record_daily_login!
        }.to change {
          user_status.reload.last_login_date
        }
        .from(Date.yesterday)
        .to(Date.current)
      end

      it "login_countが1増える" do
        expect {
          user_status.record_daily_login!
        }.to change {
          user_status.reload.login_count
        }.by(1)
      end

      it "login_streakが1増える" do
        expect {
          user_status.record_daily_login!
        }.to change {
          user_status.reload.login_streak
        }.by(1)
      end

      it "longest_login_streakとlogin_streakが同じ場合、longest_login_streakが1増える" do
        user_status.update!(login_streak: 1, longest_login_streak: 1)
        expect {
          user_status.record_daily_login!
        }.to change {
          user_status.reload.longest_login_streak
        }.by(1)
      end

      it "longest_login_streakよりlogin_streakが小さい場合、longest_login_streakは変更なし" do
        user_status.update!(login_streak: 1, longest_login_streak: 10)
        expect {
          user_status.record_daily_login!
        }.not_to change {
          user_status.reload.longest_login_streak
        }
      end
    end

    context "最終ログイン日が今日の場合" do
      before do
        user_status.update!(last_login_date: Date.current)
      end

      it "last_login_dateを変更しない" do
        expect {
          user_status.record_daily_login!
        }.not_to change {
          user_status.reload.last_login_date
        }
      end

      it "login_countを変更しない" do
        expect {
          user_status.record_daily_login!
        }.not_to change {
          user_status.reload.login_count
        }
      end

      it "login_streakを変更しない" do
        expect {
          user_status.record_daily_login!
        }.not_to change {
          user_status.reload.login_streak
        }
      end

      it "空の配列を返す" do
        expect(user_status.record_daily_login!).to eq([])
      end
    end

    context "最終ログイン日が一昨日以前の場合" do
      before do
        user_status.update!(
          last_login_date: 2.days.ago.to_date,
          login_streak: 5,
          longest_login_streak: 10
        )
      end

      it "login_streakを1にリセットする" do
        expect {
          user_status.record_daily_login!
        }.to change {
          user_status.reload.login_streak
        }.from(5).to(1)
      end

      it "longest_login_streakは変更しない" do
        expect {
          user_status.record_daily_login!
        }.not_to change {
          user_status.reload.longest_login_streak
        }
      end
    end

    context "通常のログインの場合" do
      before do
        user_status.update!(
          last_login_date: Date.yesterday,
          login_count: 1,
          login_streak: 1,
          longest_login_streak: 1
        )
      end

      it "ログインEXPが加算される" do
        expect {
          user_status.record_daily_login!
        }.to change {
          user_status.reload.experience
        }.by(UserStatus::DAILY_LOGIN_EXP)
      end

      it "ログインEXPイベントを返す" do
        events = user_status.record_daily_login!

        expect(events).to include(
          {
            type: "exp_up",
            source: "daily_login",
            exp: UserStatus::DAILY_LOGIN_EXP
          }
        )
      end
    end

    context "累計ログイン回数がボーナス条件に到達する場合" do
      before do
        user_status.update!(
          last_login_date: Date.yesterday,
          login_count: UserStatus::LOGIN_COUNT_BONUS_INTERVAL - 1,
          login_streak: 1
        )
      end

      it "ログイン回数ボーナスイベントを返す" do
        events = user_status.record_daily_login!

        expect(events).to include({
            type: "exp_up",
            source: "login_count",
            exp: UserStatus::LOGIN_COUNT_BONUS_EXP
        })
      end
    end

    context "連続ログイン回数がボーナス条件に到達する場合" do
      before do
        user_status.update!(
          last_login_date: Date.yesterday,
          login_count: 1,
          login_streak: UserStatus::LOGIN_STREAK_BONUS_INTERVAL - 1,
          longest_login_streak: UserStatus::LOGIN_STREAK_BONUS_INTERVAL - 1
        )
      end

      it "連続ログインボーナスイベントを返す" do
        events = user_status.record_daily_login!

        expect(events).to include({
            type: "exp_up",
            source: "login_streak",
            exp: UserStatus::LOGIN_STREAK_BONUS_EXP
        })
      end
    end

    context "ログインEXPによって必要EXPに到達する場合" do
      before do
        user_status.update!(
          level: 1,
          experience: 0,
          last_login_date: Date.yesterday
        )
      end

      it "レベルが上がる" do
        expect {
          user_status.record_daily_login!
        }.to change {
          user_status.reload.level
        }.from(1).to(2)
      end

      it "レベルアップイベントを返す" do
        events = user_status.record_daily_login!

        expect(events).to include(
          {
            type: "lv_up",
            level: 2
          }
        )
      end
    end
  end

  describe "#record_random_wants_limit!" do
    let(:user) { create(:user) }
    let(:user_status) { user.user_status }

    context "最終アクション日が昨日の場合" do
      before do
        user_status.update!(
          last_action_date: Date.yesterday
        )
      end

      it "last_action_dateを今日に更新する" do
        expect {
          user_status.record_random_wants_limit!
        }.to change {
          user_status.reload.last_action_date
        }.from(Date.yesterday).to(Date.current)
      end

      it "action_countが1増える" do
        expect {
          user_status.record_random_wants_limit!
        }.to change {
          user_status.reload.action_count
        }.by(1)
      end

      it "action_streakが1増える" do
        expect {
          user_status.record_random_wants_limit!
        }.to change {
          user_status.reload.action_streak
        }.by(1)
      end

      it "longest_action_streakとaction_streakが同じ場合、longest_action_streakが1増える" do
        user_status.update!(
          action_streak: 1,
          longest_action_streak: 1
        )

        expect {
          user_status.record_random_wants_limit!
        }.to change {
          user_status.reload.longest_action_streak
        }.by(1)
      end

      it "longest_action_streakよりaction_streakが小さい場合、longest_action_streakは変更しない" do
        user_status.update!(
          action_streak: 1,
          longest_action_streak: 10
        )

        expect {
          user_status.record_random_wants_limit!
        }.not_to change {
          user_status.reload.longest_action_streak
        }
      end
    end

    context "最終アクション日が今日の場合" do
      before do
        user_status.update!(
          last_action_date: Date.current
        )
      end

      it "last_action_dateを変更しない" do
        expect {
          user_status.record_random_wants_limit!
        }.not_to change {
          user_status.reload.last_action_date
        }
      end

      it "action_countを変更しない" do
        expect {
          user_status.record_random_wants_limit!
        }.not_to change {
          user_status.reload.action_count
        }
      end

      it "action_streakを変更しない" do
        expect {
          user_status.record_random_wants_limit!
        }.not_to change {
          user_status.reload.action_streak
        }
      end

      it "空の配列を返す" do
        expect(user_status.record_random_wants_limit!).to eq([])
      end
    end

    context "最終アクション日が一昨日以前の場合" do
      before do
        user_status.update!(
          last_action_date: 2.days.ago.to_date,
          action_streak: 5,
          longest_action_streak: 10
        )
      end

      it "action_streakを1にリセットする" do
        expect {
          user_status.record_random_wants_limit!
        }.to change {
          user_status.reload.action_streak
        }.from(5).to(1)
      end

      it "longest_action_streakは変更しない" do
        expect {
          user_status.record_random_wants_limit!
        }.not_to change {
          user_status.reload.longest_action_streak
        }
      end
    end

    context "通常のアクションの場合" do
      before do
        user_status.update!(
          last_action_date: Date.yesterday,
          action_count: 1,
          action_streak: 1,
          longest_action_streak: 1
        )
      end

      it "アクションEXPが加算される" do
        expect {
          user_status.record_random_wants_limit!
        }.to change {
          user_status.reload.experience
        }.by(UserStatus::DAILY_ACTION_EXP)
      end

      it "アクションEXPイベントを返す" do
        events = user_status.record_random_wants_limit!

        expect(events).to include(
          {
            type: "exp_up",
            source: "daily_action",
            exp: UserStatus::DAILY_ACTION_EXP
          }
        )
      end
    end

    context "累計アクション回数がボーナス条件に到達する場合" do
      before do
        user_status.update!(
          last_action_date: Date.yesterday,
          action_count: UserStatus::ACTION_COUNT_BONUS_INTERVAL - 1,
          action_streak: 1
        )
      end

      it "累計アクションボーナスイベントを返す" do
        events = user_status.record_random_wants_limit!

        expect(events).to include(
          {
            type: "exp_up",
            source: "action_count",
            exp: UserStatus::ACTION_COUNT_BONUS_EXP
          }
        )
      end
    end

    context "連続アクション回数がボーナス条件に到達する場合" do
      before do
        user_status.update!(
          last_action_date: Date.yesterday,
          action_count: 1,
          action_streak: UserStatus::ACTION_STREAK_BONUS_INTERVAL - 1,
          longest_action_streak: UserStatus::ACTION_STREAK_BONUS_INTERVAL - 1
        )
      end

      it "連続アクションボーナスイベントを返す" do
        events = user_status.record_random_wants_limit!

        expect(events).to include(
          {
            type: "exp_up",
            source: "action_streak",
            exp: UserStatus::ACTION_STREAK_BONUS_EXP
          }
        )
      end
    end

    context "アクションEXPによって必要EXPに到達する場合" do
      before do
        user_status.update!(
          level: 1,
          experience: 0,
          last_action_date: Date.yesterday
        )
      end

      it "レベルが上がる" do
        expect {
          user_status.record_random_wants_limit!
        }.to change {
          user_status.reload.level
        }.from(1).to(2)
      end

      it "レベルアップイベントを返す" do
        events = user_status.record_random_wants_limit!

        expect(events).to include(
          {
            type: "lv_up",
            level: 2
          }
        )
      end
    end
  end

  describe "#record_want_registration!" do
    let(:user) { create(:user) }
    let(:user_status) { user.user_status }

    context "今日まだやりたいことを登録していない場合" do
      before do
        user_status.update!(
          last_want_registration_date: Date.yesterday,
          last_action_date: Date.yesterday
        )
      end

      it "last_want_registration_dateを今日に更新する" do
        expect {
          user_status.record_want_registration!
        }.to change {
          user_status.reload.last_want_registration_date
        }.from(Date.yesterday).to(Date.current)
      end

      it "last_action_dateを今日に更新する" do
        expect {
          user_status.record_want_registration!
        }.to change {
          user_status.reload.last_action_date
        }.from(Date.yesterday).to(Date.current)
      end

      it "action_countが1増える" do
        expect {
          user_status.record_want_registration!
        }.to change {
          user_status.reload.action_count
        }.by(1)
      end

      it "action_streakが1増える" do
        expect {
          user_status.record_want_registration!
        }.to change {
          user_status.reload.action_streak
        }.by(1)
      end

      it "経験値が10増える" do
        expect {
          user_status.record_want_registration!
        }.to change {
          user_status.reload.experience
        }.by(UserStatus::DAILY_ACTION_EXP)
      end

      it "アクションEXPイベントを返す" do
        events = user_status.record_want_registration!

        expect(events).to include(
          hash_including(
            type: "exp_up",
            source: "daily_action",
            exp: UserStatus::DAILY_ACTION_EXP
          )
        )
      end
    end

    context "今日すでにやりたいことを登録している場合" do
      before do
        user_status.update!(
          last_want_registration_date: Date.current
        )
      end

      it "last_want_registration_dateを変更しない" do
        expect {
          user_status.record_want_registration!
        }.not_to change {
          user_status.reload.last_want_registration_date
        }
      end

      it "action_countを変更しない" do
        expect {
          user_status.record_want_registration!
        }.not_to change {
          user_status.reload.action_count
        }
      end

      it "空の配列を返す" do
        expect(user_status.record_want_registration!).to eq([])
      end
    end

    context "今日すでに別のアクションを実施している場合" do
      before do
        user_status.update!(
          last_want_registration_date: Date.yesterday,
          last_action_date: Date.current
        )
      end

      it "last_want_registration_dateは今日に更新する" do
        expect {
          user_status.record_want_registration!
        }.to change {
          user_status.reload.last_want_registration_date
        }.from(Date.yesterday).to(Date.current)
      end

      it "action_countは増やさない" do
        expect {
          user_status.record_want_registration!
        }.not_to change {
          user_status.reload.action_count
        }
      end

      it "experienceは増やさない" do
        expect {
          user_status.record_want_registration!
        }.not_to change {
          user_status.reload.experience
        }
      end

      it "空の配列を返す" do
        expect(user_status.record_want_registration!).to eq([])
      end
    end

    context "アクションEXPによって必要EXPに到達する場合" do
      before do
        user_status.update!(
          level: 1,
          experience: 0,
          last_action_date: Date.yesterday
        )
      end

      it "レベルが上がる" do
        expect {
          user_status.record_want_registration!
        }.to change {
          user_status.reload.level
        }.from(1).to(2)
      end

      it "レベルアップイベントを返す" do
        events = user_status.record_want_registration!

        expect(events).to include(
          {
            type: "lv_up",
            level: 2
          }
        )
      end
    end
  end

  describe "#record_signup!" do
    let(:user) { create(:user) }
    let(:user_status) { user.user_status }

    before do
      user_status.update!(
        level: 1,
        experience: 0
      )
    end

    it "experienceが増える" do
      expect {
        user_status.record_signup!
      }.to change {
        user_status.reload.experience
      }.by(10)
    end

    it "levelが上がる" do
      expect {
        user_status.record_signup!
      }.to change {
        user_status.reload.level
      }.by(1)
    end

    it "ユーザー登録EXPイベントを返す" do
      events = user_status.record_signup!

      expect(events).to include(
        hash_including(
          type: "exp_up",
          source: "signup"
        )
      )
    end

    it "レベルアップイベントを返す" do
      events = user_status.record_signup!

      expect(events).to include(
        {
          type: "lv_up",
          level: 2
        }
      )
    end

    context "Lv58でユーザー登録した場合" do
      before do
        user_status.update!(
          level: 58,
          experience: 3000
        )
      end

      it "現在レベルのrequired_exp分だけEXPが増える" do
        required_exp = user_status.required_exp_for_next_level

        expect {
          user_status.record_signup!
        }.to change {
          user_status.reload.experience
        }.by(required_exp)
      end
    end
  end

  describe "#required_exp_for_next_level" do
    let(:user) { create(:user) }
    let(:user_status) { user.user_status }

    context "Lv1の場合" do
      before do
        user_status.update!(level: 1)
      end

      it "10を返す" do
        expect(user_status.required_exp_for_next_level).to eq(10)
      end
    end

    context "Lv57の場合" do
      before do
        user_status.update!(level: 57)
      end

      it "計算結果を返す" do
        expect(user_status.required_exp_for_next_level).to eq(153)
      end
    end

    context "Lv58の場合" do
      before do
        user_status.update!(level: 58)
      end

      it "158を返す" do
        expect(user_status.required_exp_for_next_level).to eq(158)
      end
    end

    context "Lv100の場合" do
      before do
        user_status.update!(level: 100)
      end

      it "200を返す" do
        expect(user_status.required_exp_for_next_level).to eq(200)
      end
    end

    context "Lv101の場合" do
      before do
        user_status.update!(level: 101)
      end

      it "200を返す" do
        expect(user_status.required_exp_for_next_level).to eq(200)
      end
    end
  end

  describe "#exp_to_next_level" do
    let(:user) { create(:user) }
    let(:user_status) { user.user_status }

    context "Lv1で3EXP獲得している場合" do
      before do
        user_status.update!(
          level: 1,
          experience: 3
        )
      end

      it "次のレベルまでの残りEXPとして7を返す" do
        expect(user_status.exp_to_next_level).to eq(7)
      end
    end

    context "Lv2で累計12EXP獲得している場合" do
      before do
        user_status.update!(
          level: 2,
          experience: 12
        )
      end

      it "次のレベルまでの残りEXPとして8を返す" do
        expect(user_status.exp_to_next_level).to eq(8)
      end
    end
  end

  describe "#current_level_exp" do
    let(:user) { create(:user) }
    let(:user_status) { user.user_status }

    context "Lv2で累計13EXP獲得している場合" do
      before do
        user_status.update!(
          level: 2,
          experience: 13
        )
      end

      it "Lv2になってから獲得したEXPとして3を返す" do
        expect(user_status.current_level_exp).to eq(3)
      end
    end
  end
end
