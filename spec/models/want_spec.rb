require "rails_helper"

RSpec.describe Want, type: :model do
  describe "バリデーション" do
    context "contentについて" do
      it "やりたいことが登録されていれば、有効" do
        want = build(:want)
        expect(want).to be_valid
      end

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

      it "400文字なら有効" do
        want = build(:want, content: "a" * 400)
        expect(want).to be_valid
      end

      it "401文字なら有効" do
        want = build(:want, content: "a" * 401)
        expect(want).to be_invalid
      end
    end

    context "status(enum)について" do
      it "デフォルトでnot_startedになっている" do
        want = build(:want)
        expect(want.status).to eq("not_started")
      end

      it "定義されたstatusを設定できる" do
        want = build(:want, status: :in_progress)
        expect(want.status).to eq("in_progress")
      end

      it "不正なstatusを設定するとエラーになる" do
        want = build(:want, status: :invalid_status)
        expect(want).to be_invalid
      end

      it "statusがnilの場合に無効" do
        want = build(:want, status: nil)
        expect(want).to be_invalid
      end
    end
  end
end
