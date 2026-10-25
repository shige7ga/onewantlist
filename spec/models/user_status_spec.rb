require "rails_helper"

RSpec.describe UserStatus, type: :model do
  describe "バリデーション" do
    context "初期値が設定されている場合" do
      it "有効である" do
        user_status = build(:user_status)
        expect(user_status).to be_valid
      end
    end

    context "0以上の整数を許容する属性" do
      %i[
        experience
        action_count
        action_streak
        longest_action_streak
        random_gacha_count
      ].each do |attribute|

        it "#{attribute}が0なら有効" do
          status = build(:user_status, attribute => 0)
          expect(status).to be_valid
        end

        it "#{attribute}がnilなら無効" do
          status = build(:user_status, attribute => nil)
          expect(status).to be_invalid
        end

        it "#{attribute}が負数なら無効" do
          status = build(:user_status, attribute => -1)
          expect(status).to be_invalid
        end
      end
    end

    context "今日・過去・nil が有効、未来が無効となる属性" do
      %i[
        last_action_date
        last_want_registration_date
        random_gacha_date
      ].each do |attribute|

        it "#{attribute}が本日の日付なら有効" do
          status = build(:user_status, attribute => Date.current)
          expect(status).to be_valid
        end

        it "#{attribute}が過去の日付なら有効" do
          user_status = build(:user_status, attribute => Date.current - 1.day)
          expect(user_status).to be_valid
        end

        it "#{attribute}が未来の日付なら無効" do
          user_status = build(:user_status, attribute => Date.current + 1.day)
          expect(user_status).to be_invalid
        end

        it "#{attribute}がnilなら有効" do
          user_status = build(:user_status, attribute => nil)
          expect(user_status).to be_valid
        end
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
  end

  describe "ownerによるバリデーションの違い" do
    let(:login_attributes) do
      {
        last_login_date: nil,
        login_count: nil,
        login_streak: nil,
        longest_login_streak: nil
      }
    end

    it "ゲストはログイン情報がnilでも有効" do
      guest = GuestUser.create!

      status = build(
        :user_status,
        owner: guest,
        **login_attributes
      )

      expect(status).to be_valid
    end

    it "ログインユーザーはログイン情報が必須" do
      status = build(
        :user_status,
        **login_attributes
      )

      expect(status).to be_invalid
    end
  end

  describe "UserStatusとの関連" do
    it "UserStatusを紐づけられる" do
      user = create(:user)
      user_status = create(:user_status, owner: user)

      expect(user.user_status).to eq(user_status)
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

  describe "#reset_action_streak_if_expired!" do
    let(:user_status) do
      create(
        :user_status,
        action_streak: 5,
        longest_action_streak: 10
      )
    end

    it "一昨日以前なら連続記録を0にリセットする" do
      user_status.update!(
        last_action_date: 2.days.ago.to_date
      )

      user_status.reset_action_streak_if_expired!

      expect(user_status.reload).to have_attributes(
        action_streak: 0,
        longest_action_streak: 10
      )
    end

    it "昨日なら連続記録を維持する" do
      user_status.update!(
        last_action_date: Date.yesterday
      )

      expect {
        user_status.reset_action_streak_if_expired!
      }.not_to change { user_status.reload.action_streak }
    end

    it "最終アクション日がnilなら変更しない" do
      user_status.update!(last_action_date: nil)

      expect {
        user_status.reset_action_streak_if_expired!
      }.not_to change { user_status.reload.action_streak }
    end
  end

  describe "日次記録Serviceへの委譲" do
    let(:user_status) { create(:user_status) }
    let(:events) { [ { type: "exp_up", exp: 10 } ] }

    it "日次ログイン処理をRecordDailyLoginに委譲する" do
      service = instance_double(
        UserStatuses::RecordDailyLogin,
        call: events
      )

      expect(UserStatuses::RecordDailyLogin).to receive(:new)
        .with(user_status: user_status)
        .and_return(service)

      expect(user_status.record_daily_login!).to eq(events)
    end

    it "やりたいこと登録をRecordDailyActionに委譲する" do
      service = instance_double(
        UserStatuses::RecordDailyAction,
        call: events
      )

      expect(UserStatuses::RecordDailyAction).to receive(:new)
        .with(user_status: user_status, want_registration: true)
        .and_return(service)

      expect(user_status.record_want_registration!).to eq(events)
    end

    it "ガチャ上限達成をRecordDailyActionに委譲する" do
      service = instance_double(
        UserStatuses::RecordDailyAction,
        call: events
      )

      expect(UserStatuses::RecordDailyAction).to receive(:new)
        .with(user_status: user_status)
        .and_return(service)

      expect(user_status.record_random_wants_limit!).to eq(events)
    end
  end

  describe "#record_signup!" do
    let(:user) { create(:user) }
    let(:user_status) { create(:user_status, owner: user) }

    before do
      user_status.update!(
        level: 1,
        experience: 0
      )
    end

    it "登録時にEXPとレベルを更新し、イベントを返す" do
      events = user_status.record_signup!

      expect(user_status.reload).to have_attributes(
        experience: 10,
        level: 2
      )

      expect(events).to include(
        hash_including(type: "exp_up", source: "signup"),
        hash_including(type: "lv_up", source: "signup", level: 2)
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

  describe "#record_first_visit!" do
    let(:user_status) do
      create(:user_status, level: 1, experience: 0)
    end

    it "初回アクセスEXPを付与しイベントを返す" do
      events = user_status.record_first_visit!

      expect(user_status.reload).to have_attributes(
        experience: UserStatus::FIRST_VISIT_EXP,
        level: 2
      )

      expect(events).to include(
        {
          type: "exp_up",
          source: "first_visit",
          exp: UserStatus::FIRST_VISIT_EXP
        }
      )
    end
  end

  describe "#required_exp_for_next_level" do
    let(:user_status) { create(:user_status, level: 58) }

    it "現在のレベルに応じた必要EXPを返す" do
      expect(user_status.required_exp_for_next_level).to eq(158)
    end
  end

  describe "#exp_to_next_level" do
    let(:user) { create(:user) }
    let(:user_status) { create(:user_status, owner: user) }

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
    let(:user_status) { create(:user_status, owner: user) }

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
