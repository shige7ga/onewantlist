require "rails_helper"

RSpec.describe Want, type: :model do
  describe "バリデーション" do
    context "contentについて" do
      it "やりたいことが登録されていれば、有効" do
        want = build(:want)
        expect(want).to be_valid
      end

      include_examples "contentの共通バリデーション", :want
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

    context "due_dateについて" do
      it "未来の日付の登録は有効" do
        want = build(:want, due_date: 1.day.from_now)
        expect(want).to be_valid
      end

      it "今日の登録は有効" do
        want = build(:want, due_date: Time.current)
        expect(want).to be_valid
      end

      it "過去の日付の登録は有効" do
        want = build(:want, due_date: 1.day.ago)
        expect(want).to be_invalid
      end

      it "nilを許容" do
        want = build(:want, due_date: nil)
        expect(want).to be_valid
      end
    end
  end
end
