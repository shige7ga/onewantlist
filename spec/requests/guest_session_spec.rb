require "rails_helper"

RSpec.describe "ゲストセッション", type: :request do
  it "初回アクセスでゲストとステータスを作成する" do
    expect {
      get root_path
    }.to change(GuestUser, :count).by(1)
     .and change(UserStatus, :count).by(1)
  end

  it "再アクセスしてもゲストを重複作成しない" do
    get root_path

    expect {
      get guest_user_path
    }.not_to change(GuestUser, :count)
  end

  it "初回アクセスEXPを付与する" do
    get root_path

    expect(GuestUser.last.user_status.experience)
      .to eq(UserStatus::FIRST_VISIT_EXP)
  end
end
