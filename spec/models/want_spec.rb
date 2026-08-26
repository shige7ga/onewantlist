require "rails_helper"

RSpec.describe Want, type: :model do
  describe "バリデーション" do
    context "正常系" do
      it "やりたい内容が登録されていたら、やりたいこと登録できる" do
        want = build(:want)
        expect(want).to be_valid
      end
    end

    context "contentについて" do
      it "nilの場合、無効" do
        want = build(:want, content: nil)
        expect(want).to be_invalid
      end

      it "空文字の場合、無効" do
        want = build(:want, content: "")
        expect(want).to be_invalid
      end

      it "スペースのみの場合、無効" do
        want = build(:want, content: " 　 ")
        expect(want).to be_invalid
      end

      it "TABのみの場合、無効" do
        want = build(:want, content: "\t\t")
        expect(want).to be_invalid
      end

      it "contentの文字前後に空白の場合、前後空白が除去される" do
        want = build(:want, content: "  Railsの勉強をする  ")
        expect(want.content).to eq("Railsの勉強をする")
      end
    end
  end
end
