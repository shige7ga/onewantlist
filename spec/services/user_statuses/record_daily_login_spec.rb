require "rails_helper"

RSpec.describe UserStatuses::RecordDailyLogin do
  let(:user_status) do
    create(:user_status, last_login_date: Date.yesterday)
  end

  let(:service) do
    described_class.new(user_status: user_status)
  end

  describe "#call" do
    it "ログイン回数と連続日数を更新する" do
      service.call

      expect(user_status.reload).to have_attributes(
        last_login_date: Date.current,
        login_count: 2,
        login_streak: 2
      )
    end

    it "当日2回目は記録・EXPを更新しない" do
      service.call
      experience = user_status.reload.experience

      expect(service.call).to eq([])
      expect(user_status.reload.experience).to eq(experience)
      expect(user_status.login_count).to eq(2)
    end

    it "連続ログインが途切れた場合は1日目に戻す" do
      user_status.update!(
        last_login_date: 2.days.ago.to_date,
        login_streak: 5
      )

      service.call

      expect(user_status.reload.login_streak).to eq(1)
    end

    it "累計と連続が10回に到達すると両ボーナスを付与する" do
      user_status.update!(
        login_count: 9,
        login_streak: 9
      )

      events = service.call

      expect(events).to include(
        hash_including(source: "daily_login", exp: 10),
        hash_including(source: "login_count", exp: 10),
        hash_including(source: "login_streak", exp: 10)
      )
      expect(user_status.reload.experience).to eq(30)
    end

    it "別インスタンスからの重複実行も防止する" do
      other_status = UserStatus.find(user_status.id)

      service.call
      events = described_class.new(
        user_status: other_status
      ).call

      expect(events).to eq([])
      expect(user_status.reload.login_count).to eq(2)
    end


    it "最長連続ログイン記録を更新する" do
      user_status.update!(
        login_streak: 4,
        longest_login_streak: 4
      )

      service.call

      expect(user_status.reload).to have_attributes(
        login_streak: 5,
        longest_login_streak: 5
      )
    end

    it "過去の最長連続ログイン記録を維持する" do
      user_status.update!(
        login_streak: 2,
        longest_login_streak: 10
      )

      service.call

      expect(user_status.reload).to have_attributes(
        login_streak: 3,
        longest_login_streak: 10
      )
    end

    it "最終ログイン日が今日なら何も更新しない" do
      user_status.update!(last_login_date: Date.current)

      expect(service.call).to eq([])

      expect(user_status.reload).to have_attributes(
        login_count: 1,
        login_streak: 1,
        experience: 0
      )
    end

    it "ログインが途切れても最長記録は維持する" do
      user_status.update!(
        last_login_date: 2.days.ago.to_date,
        login_streak: 5,
        longest_login_streak: 10
      )

      service.call

      expect(user_status.reload).to have_attributes(
        login_streak: 1,
        longest_login_streak: 10
      )
    end

    it "累計10回で累計ボーナスのみ付与する" do
      user_status.update!(
        login_count: 9,
        login_streak: 1
      )

      events = service.call

      sources = events
        .select { |event| event[:type] == "exp_up" }
        .map { |event| event[:source] }

      expect(sources).to eq(%w[daily_login login_count])
      expect(user_status.reload.experience).to eq(20)
    end

    it "連続10日で連続ボーナスのみ付与する" do
      user_status.update!(
        login_count: 1,
        login_streak: 9,
        longest_login_streak: 9
      )

      events = service.call

      sources = events
        .select { |event| event[:type] == "exp_up" }
        .map { |event| event[:source] }

      expect(sources).to eq(%w[daily_login login_streak])
      expect(user_status.reload.experience).to eq(20)
    end

    it "通常ログインでEXPを付与しレベルアップイベントを返す" do
      events = service.call

      expect(user_status.reload).to have_attributes(
        experience: UserStatus::DAILY_LOGIN_EXP,
        level: 2
      )

      expect(events).to include(
        {
          type: "exp_up",
          source: "daily_login",
          exp: UserStatus::DAILY_LOGIN_EXP
        },
        {
          type: "lv_up",
          source: "daily_login",
          level: 2
        }
      )
    end

    it "EXP付与に失敗した場合はログイン記録を戻す" do
      allow(Experience::Grant).to receive(:new)
        .and_raise(StandardError, "EXP付与失敗")

      expect {
        service.call
      }.to raise_error(StandardError, "EXP付与失敗")

      expect(user_status.reload).to have_attributes(
        last_login_date: Date.yesterday,
        login_count: 1,
        login_streak: 1,
        experience: 0
      )
    end
  end
end
