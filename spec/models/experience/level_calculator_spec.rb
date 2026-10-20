require "rails_helper"

RSpec.describe Experience::LevelCalculator do
  describe ".required_exp_for" do
    {
      1 => 10,
      57 => 153,
      58 => 158,
      100 => 200,
      101 => 200
    }.each do |level, expected_exp|
      it "Lv#{level}の必要EXPが#{expected_exp}になる" do
        expect(described_class.required_exp_for(level)).to eq(expected_exp)
      end
    end
  end

  describe ".total_exp_for_current_level" do
    it "Lv1到達時点の累計EXPは0" do
      expect(described_class.total_exp_for_current_level(1)).to eq(0)
    end

    it "Lv3到達時点の累計EXPは20" do
      expect(described_class.total_exp_for_current_level(3)).to eq(20)
    end
  end

  describe ".total_exp_for_next_level" do
    it "Lv1から次Lvまでの累計EXPは10" do
      expect(described_class.total_exp_for_next_level(1)).to eq(10)
    end

    it "Lv3から次Lvまでの累計EXPは31" do
      expect(described_class.total_exp_for_next_level(3)).to eq(31)
    end
  end
end
