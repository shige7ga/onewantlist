require "rails_helper"

RSpec.describe UserStatuses::RecordDailyAction do
  let(:user_status) do
    create(
      :user_status,
      last_action_date: Date.yesterday,
      last_want_registration_date: Date.yesterday
    )
  end

  let(:gacha) do
    described_class.new(
      user_status: user_status
    )
  end

  let(:registration) do
    described_class.new(
      user_status: user_status,
      want_registration: true
    )
  end

  describe "#call" do
    it "やりたいこと登録時にアクションと登録日を更新する" do
      events = described_class.new(
        user_status: user_status,
        want_registration: true
      ).call

      expect(user_status.reload).to have_attributes(
        last_action_date: Date.current,
        last_want_registration_date: Date.current,
        action_count: 1,
        action_streak: 1
      )

      expect(events).to include(
        hash_including(source: "daily_action", exp: 10)
      )
    end

    it "当日すでにアクション済みなら登録日だけ更新する" do
      user_status.update!(last_action_date: Date.current)

      events = described_class.new(
        user_status: user_status,
        want_registration: true
      ).call

      expect(events).to eq([])
      expect(user_status.reload.last_want_registration_date)
        .to eq(Date.current)
      expect(user_status.action_count).to eq(0)
      expect(user_status.experience).to eq(0)
    end

    it "累計と連続が10回に到達すると両ボーナスを付与する" do
      user_status.update!(
        action_count: 9,
        action_streak: 9
      )

      events = described_class.new(
        user_status: user_status
      ).call

      expect(events).to include(
        hash_including(source: "daily_action", exp: 10),
        hash_including(source: "action_count", exp: 10),
        hash_including(source: "action_streak", exp: 10)
      )
      expect(user_status.reload.experience).to eq(30)
    end

    it "EXP付与で例外が起きたら登録・アクション更新を戻す" do
      allow(Experience::Grant).to receive(:new)
        .and_raise(StandardError, "EXP付与失敗")

      expect {
        described_class.new(
          user_status: user_status,
          want_registration: true
        ).call
      }.to raise_error(StandardError, "EXP付与失敗")

      expect(user_status.reload).to have_attributes(
        last_action_date: Date.yesterday,
        last_want_registration_date: Date.yesterday,
        action_count: 0,
        experience: 0
      )
    end

    it "最長連続アクション記録を更新する" do
      user_status.update!(
        action_streak: 4,
        longest_action_streak: 4
      )

      gacha.call

      expect(user_status.reload).to have_attributes(
        action_streak: 5,
        longest_action_streak: 5
      )
    end

    it "過去の最長連続記録を維持する" do
      user_status.update!(
        action_streak: 2,
        longest_action_streak: 10
      )

      gacha.call

      expect(user_status.reload).to have_attributes(
        action_streak: 3,
        longest_action_streak: 10
      )
    end

    it "連続記録が途切れた場合は1に戻す" do
      user_status.update!(
        last_action_date: 2.days.ago.to_date,
        action_streak: 5,
        longest_action_streak: 10
      )

      gacha.call

      expect(user_status.reload).to have_attributes(
        action_streak: 1,
        longest_action_streak: 10
      )
    end

    it "最終アクション日が今日なら何も更新しない" do
      user_status.update!(last_action_date: Date.current)

      expect(gacha.call).to eq([])

      expect(user_status.reload).to have_attributes(
        action_count: 0,
        action_streak: 0,
        experience: 0
      )
    end

    it "同じ日にガチャ達成処理を再実行しても二重計上しない" do
      gacha.call

      expect(gacha.call).to eq([])

      expect(user_status.reload).to have_attributes(
        action_count: 1,
        experience: 10
      )
    end

    it "累計10回到達時は累計ボーナスのみ付与する" do
      user_status.update!(
        action_count: 9,
        action_streak: 1
      )

      events = gacha.call

      sources = events
        .select { |event| event[:type] == "exp_up" }
        .map { |event| event[:source] }

      expect(sources).to eq(%w[daily_action action_count])
      expect(user_status.reload.experience).to eq(20)
    end

    it "連続10日到達時は連続ボーナスのみ付与する" do
      user_status.update!(
        action_count: 1,
        action_streak: 9,
        longest_action_streak: 9
      )

      events = gacha.call

      sources = events
        .select { |event| event[:type] == "exp_up" }
        .map { |event| event[:source] }

      expect(sources).to eq(%w[daily_action action_streak])
      expect(user_status.reload.experience).to eq(20)
    end

    it "ガチャ上限達成でEXPを付与しレベルアップする" do
      events = gacha.call

      expect(user_status.reload).to have_attributes(
        experience: UserStatus::DAILY_ACTION_EXP,
        level: 2
      )

      expect(events).to include(
        hash_including(
          type: "exp_up",
          source: "daily_action",
          exp: UserStatus::DAILY_ACTION_EXP
        ),
        hash_including(
          type: "lv_up",
          source: "daily_action",
          level: 2
        )
      )
    end

    it "同じ日に再登録してもアクションを更新しない" do
      registration.call

      expect(registration.call).to eq([])

      expect(user_status.reload).to have_attributes(
        last_want_registration_date: Date.current,
        action_count: 1,
        experience: 10
      )
    end

    it "ガチャ達成後の登録では登録日だけ更新する" do
      gacha.call

      events = registration.call

      expect(events).to eq([])

      expect(user_status.reload).to have_attributes(
        last_want_registration_date: Date.current,
        action_count: 1,
        experience: 10
      )
    end

    it "登録後にガチャ達成してもEXPを二重付与しない" do
      registration.call

      events = gacha.call

      expect(events).to eq([])

      expect(user_status.reload).to have_attributes(
        action_count: 1,
        experience: 10
      )
    end

    it "やりたいこと登録時にレベルアップイベントを返す" do
      events = registration.call

      expect(user_status.reload.level).to eq(2)

      expect(events).to include(
        hash_including(
          type: "lv_up",
          source: "daily_action",
          level: 2
        )
      )
    end
  end
end
