require "rails_helper"

RSpec.describe Want, type: :model do
  describe "バリデーション" do
    context "正常系" do
      it "やりたい内容が登録されていたら、やりたいこと登録できる" do
        want = build(:want)
        expect(want).to be_valid
      end
    end
  end
end
