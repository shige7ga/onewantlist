require "rails_helper"

RSpec.describe RandomWant, type: :model do
  describe "バリデーション" do
    context "contentについて" do
      it "やりたいことが登録されていれば、有効" do
        random_want = build(:random_want)
        expect(random_want).to be_valid
      end

      include_examples "contentの共通バリデーション", :random_want

      it "重複したcontentの場合、無効" do
        create(:random_want)
        random_want_non_unique = build(:random_want)
        expect(random_want_non_unique).to be_invalid
      end

      it "重複していないcontentの場合、有効" do
        create(:random_want)
        random_want_unique = build(:random_want, content: "豪華客船クルーズに乗る")
        expect(random_want_unique).to be_valid
      end
    end
  end
end
