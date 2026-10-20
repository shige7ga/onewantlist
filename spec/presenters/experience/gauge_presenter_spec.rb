require "rails_helper"

RSpec.describe Experience::GaugePresenter do
  describe "#call" do
    subject(:animation) do
      described_class.new(
        level: level,
        experience: experience,
        events: events
      ).call
    end

    context "レベルアップしない場合" do
      let(:level) { 1 }
      let(:experience) { 7 }
      let(:events) do
        [ { type: "exp_up", exp: 4 } ]
      end

      it "EXP獲得前の状態を返す" do
        expect(animation).to eq(
          start_level: 1,
          start_exp: 3,
          earned_exp: 4,
          requirements: [10]
        )
      end
    end

    context "1回レベルアップした場合" do
      let(:level) { 2 }
      let(:experience) { 13 }
      let(:events) do
        [
          { "type" => "exp_up", "exp" => 10 },
          { type: "lv_up", level: 2 }
        ]
      end

      it "文字列・シンボルキーのイベントを処理できる" do
        expect(animation).to eq(
          start_level: 1,
          start_exp: 3,
          earned_exp: 10,
          requirements: [10, 10]
        )
      end
    end

    context "複数回レベルアップした場合" do
      let(:level) { 3 }
      let(:experience) { 23 }
      let(:events) do
        [
          { type: "exp_up", exp: 20 },
          { type: "lv_up", level: 2 },
          { type: "lv_up", level: 3 }
        ]
      end

      it "通過する全レベルの必要EXPを返す" do
        expect(animation).to eq(
          start_level: 1,
          start_exp: 3,
          earned_exp: 20,
          requirements: [10, 10, 11]
        )
      end
    end

    context "イベントが存在しない場合" do
      let(:level) { 1 }
      let(:experience) { 0 }
      let(:events) { [] }

      it "nilを返す" do
        expect(animation).to be_nil
      end
    end

    context "EXP獲得イベントが存在しない場合" do
      let(:level) { 2 }
      let(:experience) { 10 }
      let(:events) do
        [ { type: "lv_up", level: 2 } ]
      end

      it "nilを返す" do
        expect(animation).to be_nil
      end
    end

    context "更新前のレベルが不正な場合" do
      let(:level) { 1 }
      let(:experience) { 10 }
      let(:events) do
        [
          { type: "exp_up", exp: 10 },
          { type: "lv_up", level: 2 }
        ]
      end

      it "nilを返す" do
        expect(animation).to be_nil
      end
    end
  end
end
