require "rails_helper"

RSpec.describe RandomWant, type: :model do
  describe "バリデーション" do
    context "contentについて" do
      it "やりたいことが登録されていれば、有効" do
        random_want = build(:random_want)
        expect(random_want).to be_valid
      end

      it "nilの場合、無効" do
        random_want = build(:random_want, content: nil)
        expect(random_want).to be_invalid
      end

      it "空文字の場合、無効" do
        random_want = build(:random_want, content: "")
        expect(random_want).to be_invalid
      end

      it "スペースのみの場合、無効" do
        random_want = build(:random_want, content: " 　 ")
        expect(random_want).to be_invalid
      end

      it "TABのみの場合、無効" do
        random_want = build(:random_want, content: "\t\t")
        expect(random_want).to be_invalid
      end

      it "contentの文字前後に空白の場合、前後空白が除去される" do
        random_want = build(:random_want, content: "  Railsの勉強をする  ")
        expect(random_want.content).to eq("Railsの勉強をする")
      end

      it "400文字なら有効" do
        random_want = build(:random_want, content: "a" * 400)
        expect(random_want).to be_valid
      end

      it "401文字なら有効" do
        random_want = build(:random_want, content: "a" * 401)
        expect(random_want).to be_invalid
      end
    end
  end
end
