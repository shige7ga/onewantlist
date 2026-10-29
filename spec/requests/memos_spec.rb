require "rails_helper"

RSpec.describe "Memos", type: :request do
  let(:user) { create(:user) }
  let!(:user_status) { create(:user_status, owner: user) }

  let(:valid_params) do
    { memo: { content: "博物館に行きたい" } }
  end

  context "ログイン時" do
    before { sign_in user }

    describe "GET /memo" do
      it "メモ画面を表示できる" do
        get memo_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("簡単メモ")
      end

      it "初回表示ではメモを作成しない" do
        expect {
          get memo_path
        }.not_to change(Memo, :count)

        expect(response).to have_http_status(:ok)
      end

      it "保存済みのメモ内容を表示する" do
        create(:memo, user: user, content: "旅行の計画")

        get memo_path

        document = response.parsed_body
        textarea = document.at_css("#memo_content")

        expect(textarea.text).to eq("旅行の計画")
      end
    end

    describe "PATCH /memo" do
      it "初回保存時にメモを1件作成する" do
        expect {
          patch memo_path, params: valid_params
        }.to change(Memo, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(user.memo.reload.content).to eq("博物館に行きたい")
      end

      it "2回目以降は既存のメモを更新する" do
        memo = create(:memo, user: user, content: "元のメモ")

        expect {
          patch memo_path, params: valid_params
        }.not_to change(Memo, :count)

        expect(memo.reload.content).to eq("博物館に行きたい")
        expect(response).to have_http_status(:ok)
      end

      it "空文字でも保存できる" do
        memo = create(:memo, user: user, content: "元のメモ")

        patch memo_path, params: {
          memo: { content: "" }
        }

        expect(response).to have_http_status(:ok)
        expect(memo.reload.content).to eq("")
      end

      it "2001文字以上の場合は保存できない" do
        memo = create(:memo, user: user, content: "元のメモ")

        patch memo_path, params: {
          memo: { content: "a" * 2001 }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(memo.reload.content).to eq("元のメモ")
        expect(response.parsed_body["error"]).to be_present
      end
    end

    describe "他ユーザーのメモ" do
      let(:other_user) do
        create(:user, email: "other@example.com")
      end

      let!(:other_memo) do
        create(:memo, user: other_user, content: "他人の秘密メモ")
      end

      it "他ユーザーのメモを閲覧できない" do
        get memo_path

        expect(response.body).not_to include("他人の秘密メモ")
      end

      it "他ユーザーのメモを変更できない" do
        patch memo_path, params: {
          memo: {
            content: "自分のメモ",
            user_id: other_user.id
          }
        }

        expect(response).to have_http_status(:ok)
        expect(other_memo.reload.content).to eq("他人の秘密メモ")
        expect(Memo.find_by!(user: user).content).to eq("自分のメモ")
      end
    end
  end

  context "未ログイン時" do
    it "メモ画面へアクセスするとログイン画面に遷移する" do
      get memo_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "メモを保存できない" do
      expect {
        patch memo_path, params: valid_params
      }.not_to change(Memo, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
