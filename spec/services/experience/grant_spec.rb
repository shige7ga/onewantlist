require "rails_helper"

RSpec.describe Experience::Grant do
  let(:user_status) do
    create(:user_status, level: 1, experience: 0)
  end

  subject(:grant) do
    described_class.new(
      user_status: user_status,
      exp_events: exp_events
    ).call
  end

  describe "#call" do
    context "レベルアップしない場合" do
      let(:exp_events) do
        [ { type: "exp_up", source: "daily_login", exp: 5 } ]
      end

      it "EXPだけを加算する" do
        expect(grant).to eq(exp_events)

        expect(user_status.reload).to have_attributes(
          experience: 5,
          level: 1
        )
      end
    end

    context "レベルアップする場合" do
      let(:exp_events) do
        [ { type: "exp_up", source: "daily_login", exp: 10 } ]
      end

      it "EXPとレベルを更新し、イベントを返す" do
        expect(grant).to eq([
          exp_events.first,
          { type: "lv_up", source: "daily_login", level: 2 }
        ])

        expect(user_status.reload).to have_attributes(
          experience: 10,
          level: 2
        )
      end
    end

    context "複数のEXPイベントがある場合" do
      let(:exp_events) do
        [
          { type: "exp_up", source: "daily_login", exp: 10 },
          { type: "exp_up", source: "login_count", exp: 11 }
        ]
      end

      it "イベント順にEXPを付与してレベルアップする" do
        expect(grant).to eq([
          exp_events.first,
          { type: "lv_up", source: "daily_login", level: 2 },
          exp_events.last,
          { type: "lv_up", source: "login_count", level: 3 }
        ])

        expect(user_status.reload).to have_attributes(
          experience: 21,
          level: 3
        )
      end
    end

    context "一度に複数レベルアップする場合" do
      let(:exp_events) do
        [ { type: "exp_up", source: "signup", exp: 35 } ]
      end

      it "到達した全レベルのイベントを返す" do
        expect(grant).to eq([
          exp_events.first,
          { type: "lv_up", source: "signup", level: 2 },
          { type: "lv_up", source: "signup", level: 3 },
          { type: "lv_up", source: "signup", level: 4 }
        ])

        expect(user_status.reload).to have_attributes(
          experience: 35,
          level: 4
        )
      end
    end

    context "EXPイベントが空の場合" do
      let(:exp_events) { [] }

      it "イベントを返さず、EXPとレベルを維持する" do
        expect(grant).to eq([])

        expect(user_status.reload).to have_attributes(
          experience: 0,
          level: 1
        )
      end
    end
  end
end
