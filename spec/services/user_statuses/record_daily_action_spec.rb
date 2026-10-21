require "rails_helper"

RSpec.describe UserStatuses::RecordDailyAction do
  let(:user_status) do
    create(
      :user_status,
      last_action_date: Date.yesterday,
      last_want_registration_date: Date.yesterday
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
  end
end
